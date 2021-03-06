Decks.Show.Tabs = React.createClass({
  propTypes: {
    activeComponent: React.PropTypes.string.isRequired,
    handleSwitchTab: React.PropTypes.func.isRequired,
    cardSuggestions: React.PropTypes.array.isRequired,
    cards: React.PropTypes.array.isRequired,
    cardEdits: React.PropTypes.array.isRequired,
    deck: React.PropTypes.object.isRequired
  },

  render: function() {
    var style = {
      marginBottom: '-5px'
    };

    return (
      <div style={style} >
        <ul className="nav nav-tabs">
          <DeckTab
            text={ViewHelpers.pluralizeCard(this.props.cards.length, true)}
            active={this.props.activeComponent === "Card List"}
            handleSwitchTab={this.props.handleSwitchTab}
            callbackAttribute="Card List"
          />
          <DeckTab
            text="Pending New Cards"
            active={this.props.activeComponent === "New Card Suggestions"}
            handleSwitchTab={this.props.handleSwitchTab}
            cardSuggestionsCount={this.props.cardSuggestionsCount}
            callbackAttribute="New Card Suggestions"
          />
          <DeckTab
            text="Pending Card Edits"
            active={this.props.activeComponent === "Card Edits"}
            handleSwitchTab={this.props.handleSwitchTab}
            callbackAttribute="Card Edits"
          />
          <DeckTab
            text="Discussion"
            handleSwitchTab={doNothing}
            callbackAttribute=""
            // this is actually just a link.
            href={this.props.deck.deck_discussions_path}
          />
          <DeckTab
            text="Contributors"
            active={this.props.activeComponent === "Contributors"}
            handleSwitchTab={this.props.handleSwitchTab}
            callbackAttribute="Contributors"
          />
        </ul>
      </div>
    )
  }
})