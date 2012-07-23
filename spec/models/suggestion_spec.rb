require 'spec_helper'

describe Suggestion do
  it { should validate_presence_of(:primary).with_message(/This field is required/) }

  it { should belong_to :event }
  it { should have_many(:votes).dependent(:destroy) }

  it { should allow_mass_assignment_of(:primary) }
  it { should allow_mass_assignment_of(:secondary) }
  it { should allow_mass_assignment_of(:event) }
end

describe Suggestion, '#vote_count' do
  it 'returns the number of votes for this suggestion' do
    suggestion_with_three_votes = create(:suggestion, votes: create_list(:vote, 2))
    suggestion_with_three_votes.vote_count.should == 2
  end

  it 'returns 0 votes when no votes exist' do
    suggestion_with_no_votes = create(:suggestion)
    suggestion_with_no_votes.vote_count.should == 0
  end

  it 'returns 0 votes when an unpersisted vote shows up for no reason' do
    suggestion_with_no_votes = create(:suggestion)
    suggestion_with_no_votes.votes.build
    suggestion_with_no_votes.vote_count.should == 0
  end
end

describe Suggestion, '#user_voted?' do
  it 'returns true if the user has voted on the event' do
    user = create(:user)
    suggestion = build_stubbed(:suggestion)
    vote = create(:vote_by_user, user: user, suggestion: suggestion)


    suggestion.should be_user_voted(user)
  end

  it 'returns false if the user has not voted on the event' do
    user = create(:user)
    suggestion = build_stubbed(:suggestion)

    suggestion.should_not be_user_voted(build(:user))
  end
end
