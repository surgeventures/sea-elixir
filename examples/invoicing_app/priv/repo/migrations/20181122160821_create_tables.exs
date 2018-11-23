defmodule InvoicingApp.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:customers_accounts) do
      add :name, :string, null: false
      add :active, :boolean, null: false, default: false

      timestamps()
    end

    create table(:inventory_products) do
      add :stock, :integer, null: false, default: 0

      timestamps()
    end

    create constraint(:inventory_products, :stock_cannot_be_negative, check: "stock >= 0")

    create table(:sales_invoices) do
      add :product_id, references(:inventory_products), null: false
      add :customer_id, references(:customers_accounts), null: false
      add :number, :string, null: false

      timestamps()
    end

    create index(:sales_invoices, [:number], unique: true)

    create table(:analytics_customer_invoice_counters) do
      add :customer_id, references(:customers_accounts), null: false
      add :invoice_count, :integer, null: false, default: 0
    end

    create index(:analytics_customer_invoice_counters, [:customer_id], unique: true)
  end
end
