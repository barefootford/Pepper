def create_user
  @user = User.create!(user_attributes)
end

def create_second_user
  @user2 = User.create!(user_attributes(first_name:'Second', last_name:'Swanson', email:'user2@example.com'))
end

def create_deck
  @deck = Deck.create!(deck_attributes)
end

def create_user_deck_cards
  create_user
  create_deck
  create_cards_for(Deck.last)
end

def create_cards_for(deck)
  1.upto(3) do
    deck.cards.create!(user_id: User.first.id,
                       deck_id: User.first.id,
                       question: "Who is the CTO of #{Faker::Company.name}?",
                       answer: Faker::Name.name)
  end
end
 
def create_card
  @card = @deck.cards.create!(card_attributes)
end

def create_deck_and_card
  create_deck
  create_card
end

def create_user_and_sign_in
  create_user
  sign_in(@user)
end

def create_card_suggestion
  @card_suggestion = CardSuggestion.create!(card_attributes)
end

def sign_in(user)
  visit new_session_path
  fill_in 'email', with: user.email
  fill_in 'password', with: user_attributes[:password]
  click_on 'sign-in-btn'
end

def user_attributes(overrides = {})
  {
    first_name: 'Example',
    last_name: 'User',
    email: 'user@example.com',
    password: 'secret',
    password_confirmation: 'secret',
    beta_status: :approved
  }.merge(overrides)
end

def deck_attributes(overrides = {})
  {
    title:'Pragmatic Studio Ruby Notes',
    user_id: 1,
    instructions:"Use this deck promptly after finishing the class and you'll do really well."
  }.merge(overrides)
end

def card_suggestion_attributes
  card_attributes(user_id: 2)
end

def card_attributes(overrides = {})
  {
    deck_id: 1,
    question: 'Is the sky blue?',
    answer: 'Yes',
    user_id: deck_attributes[:user_id]
  }.merge(overrides)
end

def deck_subscription_attributes(overrides = {})
  {
    user_id: 1,
    deck_id: 1
  }.merge(overrides)
end

def create_deck_subscription(user, deck)
  DeckSubscription.create!(user_id: user.id, deck_id: deck.id)
end