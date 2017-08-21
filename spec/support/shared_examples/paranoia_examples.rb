RSpec.shared_examples_for 'a Paranoid model' do

  it { should have_db_column(:deleted_at) }

  it { should have_db_index(:deleted_at) }

  it 'adds a deleted_at where clause' do
    described_class.default_scoped.where_sql.should include("\"deleted_at\" IS NULL")
  end

  it 'skips adding the deleted_at where clause when unscoped' do
    described_class.unscoped.where_sql.to_s.should_not include("deleted_at")
  end

end
