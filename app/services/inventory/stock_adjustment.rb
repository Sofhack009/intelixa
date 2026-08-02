module Inventory
  class StockAdjustment
    Result = Data.define(:batch, :movement)

    def self.call(**args)
      new(**args).call
    end

    def initialize(item:, warehouse:, batch_number:, quantity_delta:, movement_type:, unit_cost:, user: nil, reference: nil, expiry_date: nil)
      @item = item
      @warehouse = warehouse
      @batch_number = batch_number
      @quantity_delta = quantity_delta.to_i
      @movement_type = movement_type
      @unit_cost = unit_cost
      @user = user
      @reference = reference
      @expiry_date = expiry_date
    end

    def call
      raise ArgumentError, "quantity_delta cannot be zero" if @quantity_delta.zero?

      InventoryBatch.transaction do
        batch = InventoryBatch.lock.find_by(
          item: @item,
          warehouse: @warehouse,
          batch_number: @batch_number
        )

        if batch.nil?
          raise ActiveRecord::RecordNotFound, "Inventory batch not found" if @quantity_delta.negative?

          batch = InventoryBatch.create!(
            item: @item,
            warehouse: @warehouse,
            batch_number: @batch_number,
            quantity: 0,
            unit_cost: @unit_cost,
            expiry_date: @expiry_date
          )
        end

        new_quantity = batch.quantity + @quantity_delta
        raise ActiveRecord::RecordInvalid, "Insufficient stock" if new_quantity.negative?

        batch.update!(quantity: new_quantity, unit_cost: @unit_cost)

        movement = StockMovement.create!(
          item: @item,
          warehouse: @warehouse,
          movement_type: @movement_type,
          quantity_delta: @quantity_delta,
          unit_cost: @unit_cost,
          created_by: @user,
          reference: @reference,
          occurred_at: Time.current
        )

        Result.new(batch, movement)
      end
    end
  end
end
