# Preview all emails at http://localhost:3000/rails/mailers/correspondence_mailer
class CorrespondenceMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/correspondence_mailer/correspondence
  def correspondence
    CorrespondenceMailer.correspondence(
      Store.find(24),
      {
        subject: 'Yhteydenotto',
        name: 'Jukka-Pekka Palo',
        email: 'jpp@gmail.com',
        phone: '555-1234',
        message: 'Tähän hieno viesti.'
      }
    )
  end
end
