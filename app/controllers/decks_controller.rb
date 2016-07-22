class DecksController < ApplicationController
  before_action :require_sign_in, except: [:show, :index]
  before_action :deck, only: [:show, :edit, :update, :destroy, :download]
  before_action :require_creator, only: [:edit, :update, :destroy]
  before_action :dont_show_edit_button, only: [:show]
  before_action :do_show_edit_button, only: [:edit]
  before_action :must_be_beta_approved

  def anki_import
    respond_to do |format|
      format.js { render :anki_import }
    end
  end

  def show
    @card_suggestion = CardSuggestion.new
    @card_suggestions = @deck.card_suggestions.select {|cs| cs.pending?}
      .map {|cs| CardSuggestion.addClientSideAttributes(cs)}
    # need to make this scoped to only include pendign card edits, like in #edit
    @cards = deck.cards.includes(:user, :card_edits)
    @cards_with_client_side_attributes = @cards.collect do |card|
      card = Card.addClientSideAttributes(card)
    end

    @card_edits = @cards.collect {|card| card.card_edits}
      .flatten
      .select {|ce| ce.pending? }
      .map {|ce| ce.serializable_hash }

    set_deck_subscription if current_user.present?

    respond_to do |format|
      format.html
      format.csv { download_csv }
    end
  end

  def edit
    @card_suggestions = @deck.card_suggestions.pending.includes(:user)
    @card_suggestions_with_client_side_attributes = @card_suggestions.collect do |cs|
      cs = CardSuggestion.addClientSideAttributes(cs)
    end

    @deck_editor = @deck.user
    @new_card = @deck.cards.build
    @cards = @deck.cards.saved.includes(:user, :card_edits)

    @cards_with_client_side_attributes = @cards.collect do |card|
      card = Card.addClientSideAttributes(card)
    end

    @card_edits = @cards.collect {|card| card.card_edits }.flatten
      .select {|ce| ce.pending? }
      .map {|ce| ce.serializable_hash }
  end

  def update
    if @deck.update(deck_params)
      payload = {
        errors: [],
        flash: "Deck updated successfully.",
        deck: { title: @deck.title, instructions: @deck.instructions}
      }
      status = 200
    else
      payload = {
        errors: @deck.errors.messages,
        flash: ""
      }
      status = 422
    end
    render json: payload, status: status
  end

  def destroy
    @deck.destroy
    redirect_to root_url, notice: "#{@deck.title} deck deleted successfully."
  end

  def new
    @new_deck = current_user.decks.build
  end

  def create
    @new_deck = current_user.decks.new(deck_params)
    if @new_deck.save
       redirect_to edit_deck_path(@new_deck), notice: "Deck built successfully."
    else
      render :new
    end
  end

private
  def set_deck_subscription
    if current_user.deck_subscriptions.where(deck: deck).any?
      @deck_subscription = current_user.deck_subscriptions.where(deck: deck).first
    else
      @new_deck_subscription = current_user.deck_subscriptions.new(deck: deck) 
    end
  end

  def download_csv
    send_data @deck.to_csv, filename: @deck.file_name
  end

  def dont_show_edit_button
    @show_edit_button = false
  end

  def do_show_edit_button
    @show_edit_button = true
  end

  def require_creator
    unless current_user && current_user == deck.user
      redirect_to root_url, notice: "Only the deck's creator can edit the deck."
    end
  end

  def set_deck
    deck
  end

  def deck
    @deck ||= Deck.includes(:user, :card_suggestions).find(params[:id])
    # users = User.includes(:address, friends: [:address, :followers])
  end

  def deck_params
    params.require(:deck).permit(:title,:editor,:instructions)
  end
end