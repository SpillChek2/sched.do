class UserMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  NO_REPLY_FROM_EMAIL = '<no-reply@sched.do>'
  default from: %("sched.do" #{NO_REPLY_FROM_EMAIL})

  def event_created_confirmation(event)
    @event = event
    @creator = @event.owner

    mail(
      to: @creator.email,
      from: NO_REPLY_FROM_EMAIL,
      subject: "You created #{@event.name} on sched.do"
    )
  end

  def invitation(invitation)
    @guest = invitation.invitee
    @sender = invitation.sender
    @event = EventDecorator.decorate(invitation.event)

    mail(
      to: @guest.email,
      from: from_text(@sender.name),
      subject: "Help out #{@event.owner}"
    )
  end

  def reminder(invitation, sender)
    @guest = invitation.invitee
    @sender = sender
    @event = EventDecorator.decorate(invitation.event)

    mail(
      to: @guest.email,
      from: from_text(@sender.name),
      subject:
        "Reminder: Help out #{@sender.name} by voting on #{@event.name}"
    )
  end

  def vote_confirmation(vote)
    @user = vote.voter
    @event = vote.suggestion.event

    mail(
      to: @user.email,
      subject: %{Thanks for voting on "#{truncate(@event.name, length: 23)}" on sched.do}
    )
  end

  private

  def from_text(user_name = nil)
    %("sched.do on behalf of #{user_name}" #{NO_REPLY_FROM_EMAIL})
  end
end
