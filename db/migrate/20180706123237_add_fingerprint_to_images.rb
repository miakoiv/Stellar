# After this migration, run the rake task to generate the fingerprints:
# CLASS=Image ATTACHMENT=attachment rake paperclip:refresh:fingerprints
class AddFingerprintToImages < ActiveRecord::Migration
  def change
    add_column :images, :attachment_fingerprint, :string, after: :purpose
  end
end
