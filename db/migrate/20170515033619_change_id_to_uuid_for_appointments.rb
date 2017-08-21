class ChangeIdToUuidForAppointments < ActiveRecord::Migration
  def up
    change_appointments_id_to_uuid
    change_sessions_foreign_key_to_appointments
    change_client_appointments_foreign_key_to_appointments
  end

  def down
    reverse_appointments_id_to_uuid
    reverse_sessions_appointment_id
    reverse_client_appointments_appointment_id
  end

  private

  def change_appointments_id_to_uuid
    execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

    add_column :appointments, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :appointments do |t|
      t.rename :id, :old_id
      execute "ALTER TABLE appointments DROP CONSTRAINT appointments_pkey;"
      t.rename :uuid, :id
    end

    execute "ALTER TABLE appointments ADD PRIMARY KEY (id);"

    change_column_null :appointments, :old_id, true
  end

  def change_sessions_foreign_key_to_appointments
    add_column :sessions, :uuid_appointment_id, :uuid, null: true
    rename_column :sessions, :appointment_id, :old_appointment_id
    rename_column :sessions, :uuid_appointment_id, :appointment_id

    execute "UPDATE
              sessions s1
            SET
              appointment_id = a.id
            FROM
              appointments a
              INNER JOIN sessions s ON (a.old_id = s.old_appointment_id)
            WHERE
              s1.id = s.id;"
  end

  def change_client_appointments_foreign_key_to_appointments
    add_column :client_appointments, :uuid_appointment_id, :uuid, null: true
    rename_column :client_appointments, :appointment_id, :old_appointment_id
    rename_column :client_appointments, :uuid_appointment_id, :appointment_id

    execute "UPDATE
              client_appointments s1
            SET
              appointment_id = a.id
            FROM
              appointments a
              INNER JOIN client_appointments s ON (a.old_id = s.old_appointment_id)
            WHERE
              s1.id = s.id;"
  end

  def reverse_appointments_id_to_uuid
    change_column_null :appointments, :old_id, false

    change_table :appointments do |t|
      t.rename :id, :uuid
      execute "ALTER TABLE appointments DROP CONSTRAINT appointments_pkey;"
      t.rename :old_id, :id

      t.remove :uuid
    end

    execute "ALTER TABLE appointments ADD PRIMARY KEY (id);"
  end

  def reverse_sessions_appointment_id
    rename_column :sessions, :appointment_id, :uuid_appointment_id

    rename_column :sessions, :old_appointment_id, :appointment_id

    remove_column :sessions, :uuid_appointment_id
  end
end
