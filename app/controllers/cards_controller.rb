class CardsController < ApplicationController
  before_action :set_deck, only: [:create, :update]
  before_action :set_card, only: [:update]
  before_action :require_sign_in
  before_action :can_create?, only: [:create, :update]
  before_action :must_be_beta_approved

  def create
    @show_edit_button = true
    @card = set_deck.cards.new(card_params)
    @card.user_id = current_user.id
    @card.save

    respond_to do |format|
      format.js { create_card_js }
      format.json { @card.save; render json: Card.addClientSideAttributes(card_or_errors) }
    end
  end

  def destroy
    @card = Card.find(deck_params[:id])
    @deck = Deck.find(@card.deck.id)

    return not_permitted unless current_user_owns(@card.deck)

    if @card.destroy
      respond_to do |format|
        format.json { render json: @card, status: 200}
        format.js { render :deleted }
        format.html { redirect_to edit_deck_path(@deck), notice: 'Card deleted.', status: 303 }
      end
    else
      respond_to :json, :js, :html
      respond_with(@card, status: 400)
    end
  end

  def update
    if @card.update(question: card_params[:question], answer: card_params[:answer])
      respond_to do |format|
        format.json {
          card = Card.addClientSideAttributes(@card)
          render json: card
        }
        format.html { redirect_to edit_deck_path(@card.deck), notice: "Card successfully updated." }
      end
    else
      set_update_objects
      respond_to do |format|
        format.json { byebug }
        format.html { render template: 'decks/edit' }
      end
    end
  end

private
  def card_or_errors
    if @card.try(:errors).try(:any?)
      @card.errors
    else
      @card
    end
  end

  def set_update_objects
    @card_suggestions = @deck.card_suggestions.pending
    @new_card = @deck.cards.build
    @cards = @deck.cards.saved
  end

  def can_create?
    not_permitted unless current_user_owns(set_deck)
  end

  def create_card_js
    if @card.save
      render :create
    else
      render :errors
    end
  end

  def card_params
    params.require(:card).permit(:id, :question, :answer).merge(deck_params)
  end

  def deck_params
    params.permit(:id, :deck_id)
  end

  def set_card
    @card ||= Card.find(card_params[:id])
  end

  def set_deck
    @deck ||= Deck.find(card_params[:deck_id])
  end
end
