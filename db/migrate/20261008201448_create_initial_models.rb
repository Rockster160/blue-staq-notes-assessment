class CreateInitialModels < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.text :username
      t.text :email
      t.string :password_digest

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true

    create_table :teams do |t|
      # Might also add an org here if this was going to be more than an internal tool
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.text :name

      t.timestamps
    end

    create_table :notes do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :team, null: false, foreign_key: true

      t.text :title
      t.text :body

      t.timestamps
    end

    create_table :memberships do |t|
      t.references :user, null: false
      t.references :team, null: false
      # Maybe add a role if we want editor vs viewer separate

      t.timestamps
    end
    add_index :memberships, [:user_id, :team_id], unique: true
  end
end
