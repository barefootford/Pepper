var DeckTitle = React.createClass({
  editLink: function() {
    var data = this.props.data;
    var deckEditorIsCurrentUser = data.deckEditor.id === data.currentUser.id;

    if (deckEditorIsCurrentUser && (data.currentPage === 'show')) {
      return(
        <span>
        | <a href={"/decks/" + data.deckID + "/edit"}> edit deck</a>
        </span>
      )
    } else if (deckEditorIsCurrentUser && data.currentPage === 'edit'){
      return (
        <span>
          | <a href={"/decks/" + data.deckID}>view deck</a>
        </span>
      )
    } else {
      return null
    }
  },
  render: function() {
    var data = this.props.data;
    var headStyle = {
      marginBottom: '-4px'
    };

    var cardCountString = ViewHelpers.pluralizeCard(data.cards.length);
    var contributionCount = ViewHelpers.communityContributionsCount(data.cards, data.deckEditor.id);
    var contributionString = ViewHelpers.pluralizeContrib(contributionCount);

    return (
      <div>
        <h3 style={headStyle}>{data.deckTitle}</h3>
        <small>
          by <a href={"/users/" + data.deckEditor.id}>{data.deckEditor.name}</a>
          {' | ' + cardCountString}
          {' | ' + contributionString }
          { this.editLink() }
        </small>
        <hr/>
      </div>
    )
  }
});
