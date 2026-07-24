# db/seeds.rb
puts "Clearing old data..."
WastageLog.destroy_all
QualityInspection.destroy_all
JobWorkItem.destroy_all
JobWorkChallan.destroy_all
JobWorker.destroy_all
InventoryBatch.destroy_all
Warehouse.destroy_all
Item.destroy_all

# Realistic textile-manufacturing dataset for Intelixa.
# Models a composite mill workflow: yarn -> grey fabric (woven on job work) ->
# dyeing/printing (job work) -> finishing -> finished fabric/garments,
# with the chemicals/dyes consumed along the way, quality checks at each
# handoff, and wastage logged where material is lost.
#
# Safe to re-run: everything is looked up with find_or_create_by! on a
# natural key (sku_code, name, batch_number, etc.) so seeding twice will
# not create duplicates.
#
# Run with: bin/rails db:seed

puts "== Seeding Intelixa textile demo data =="

# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------
admin = User.find_or_create_by!(email: "admin@intelixa-textiles.test") do |u|
  u.password = "Password@123"
  u.password_confirmation = "Password@123"
end
puts "Users: 1 (#{admin.email})"

# ---------------------------------------------------------------------------
# Warehouses — a typical composite-mill footprint spread across textile hubs
# ---------------------------------------------------------------------------
warehouses_data = [
  { name: "Raw Material Godown",        location: "Bhiwandi, Maharashtra" },
  { name: "Grey Fabric Warehouse",      location: "Bhiwandi, Maharashtra" },
  { name: "Dyeing Unit Store",          location: "Ichalkaranji, Maharashtra" },
  { name: "Finished Goods Warehouse",   location: "Surat, Gujarat" },
  { name: "Job Work Holding Store",     location: "Tirupur, Tamil Nadu" }
]

warehouses = warehouses_data.map do |w|
  Warehouse.find_or_create_by!(name: w[:name]) { |rec| rec.location = w[:location] }
end
wh_raw, wh_grey, wh_dye, wh_finished, wh_jobwork = warehouses
puts "Warehouses: #{warehouses.size}"

# ---------------------------------------------------------------------------
# Items — yarns, grey/finished fabric, dyes & chemicals, trims, finished goods
# HSN codes reflect real textile chapter headings (52 cotton, 54 synthetic
# filament, 55 synthetic staple, 32 dyes/tanning extracts, 28 inorganic
# chemicals, 62 apparel).
# ---------------------------------------------------------------------------
items_data = [
  # Yarns (raw material)
  { sku: "YRN-CTN-30S",  name: "Cotton Yarn 30s Count",          category: "Yarn",             item_type: "raw_material",  hsn: "5205", min_stock: 2000 },
  { sku: "YRN-CTN-40S",  name: "Cotton Yarn 40s Count",          category: "Yarn",             item_type: "raw_material",  hsn: "5205", min_stock: 1500 },
  { sku: "YRN-PSF-150D", name: "Polyester Filament Yarn 150D",   category: "Yarn",             item_type: "raw_material",  hsn: "5402", min_stock: 1000 },
  { sku: "YRN-VIS-30S",  name: "Viscose Yarn 30s Count",         category: "Yarn",             item_type: "raw_material",  hsn: "5510", min_stock: 800 },

  # Grey (unfinished woven) fabric — semi-finished, produced via job work weaving
  { sku: "FAB-GRY-POP",  name: "Grey Fabric - Poplin 60x60",     category: "Grey Fabric",      item_type: "semi_finished", hsn: "5208", min_stock: 3000 },
  { sku: "FAB-GRY-TWL",  name: "Grey Fabric - Twill 2/1",        category: "Grey Fabric",      item_type: "semi_finished", hsn: "5209", min_stock: 2000 },

  # Finished fabric — after dyeing/printing/finishing job work
  { sku: "FAB-DYE-NVY",  name: "Dyed Fabric - Navy Blue",        category: "Finished Fabric",  item_type: "finished_good", hsn: "5208", min_stock: 1000 },
  { sku: "FAB-DYE-MRN",  name: "Dyed Fabric - Maroon",           category: "Finished Fabric",  item_type: "finished_good", hsn: "5208", min_stock: 1000 },
  { sku: "FAB-PRT-FLR",  name: "Printed Fabric - Floral Design", category: "Finished Fabric",  item_type: "finished_good", hsn: "5208", min_stock: 500 },

  # Dyes & process chemicals — consumables used up during job work
  { sku: "DYE-RCT-RED",  name: "Reactive Dye - Red RB",          category: "Dyes & Chemicals", item_type: "consumable",    hsn: "3204", min_stock: 100 },
  { sku: "DYE-RCT-BLK",  name: "Reactive Dye - Black WNN",       category: "Dyes & Chemicals", item_type: "consumable",    hsn: "3204", min_stock: 100 },
  { sku: "CHM-CAU-FLK",  name: "Caustic Soda Flakes",            category: "Dyes & Chemicals", item_type: "consumable",    hsn: "2815", min_stock: 500 },
  { sku: "CHM-SOD-ASH",  name: "Soda Ash Light",                 category: "Dyes & Chemicals", item_type: "consumable",    hsn: "2836", min_stock: 500 },
  { sku: "CHM-H2O2-50",  name: "Hydrogen Peroxide 50%",          category: "Dyes & Chemicals", item_type: "consumable",    hsn: "2847", min_stock: 200 },

  # Trims — bought-out trading items (deliberately excluded from inventory
  # valuation by DashboardController, so they double as a check on that logic)
  { sku: "TRM-BTN-4H",   name: "Buttons - Plastic 4 Hole",       category: "Trims",            item_type: "trading_product", hsn: "9606", min_stock: 5000 },
  { sku: "TRM-ZIP-N5",   name: "Zippers - Nylon #5",             category: "Trims",            item_type: "trading_product", hsn: "9607", min_stock: 2000 },

  # Finished goods (cut & sew output)
  { sku: "FG-SHIRT-M",   name: "Finished Garment - Men's Shirt", category: "Garments",         item_type: "finished_good", hsn: "6205", min_stock: 200 }
]

items = items_data.each_with_object({}) do |i, memo|
  memo[i[:sku]] = Item.find_or_create_by!(sku_code: i[:sku]) do |rec|
    rec.name = i[:name]
    rec.category = i[:category]
    rec.item_type = i[:item_type]
    rec.hsn_code = i[:hsn]
    rec.min_stock_level = i[:min_stock]
  end
end
puts "Items: #{items.size}"

# ---------------------------------------------------------------------------
# Job Workers — outside processing units the mill sends material to
# ---------------------------------------------------------------------------
job_workers_data = [
  { name: "Shree Ganesh Dyeing Works",   process: "Dyeing",    rate: 18.50 },
  { name: "Balaji Weaving Mills",        process: "Weaving",   rate: 6.75 },
  { name: "Om Printing Works",           process: "Printing",  rate: 22.00 },
  { name: "New Rajlaxmi Processors",     process: "Finishing", rate: 9.25 },
  { name: "Sai Stitching Unit",          process: "Stitching", rate: 35.00 }
]

job_workers = job_workers_data.map do |jw|
  JobWorker.find_or_create_by!(name: jw[:name]) do |rec|
    rec.process_type = jw[:process]
    rec.rate_per_unit = jw[:rate]
  end
end
jw_dyeing, jw_weaving, jw_printing, jw_finishing, jw_stitching = job_workers
puts "Job Workers: #{job_workers.size}"

# ---------------------------------------------------------------------------
# Inventory Batches — lots sitting in each warehouse, lot numbers follow a
# "FY LOT" convention common on Indian mill floors
# ---------------------------------------------------------------------------
inventory_batches_data = [
  { item: "YRN-CTN-30S",  wh: wh_raw,      batch: "LOT/25-26/0118", qty: 4200, cost: 245.00, expiry: nil },
  { item: "YRN-CTN-40S",  wh: wh_raw,      batch: "LOT/25-26/0119", qty: 3100, cost: 268.50, expiry: nil },
  { item: "YRN-PSF-150D", wh: wh_raw,      batch: "LOT/25-26/0142", qty: 2600, cost: 132.00, expiry: nil },
  { item: "YRN-VIS-30S",  wh: wh_raw,      batch: "LOT/25-26/0151", qty: 1400, cost: 189.75, expiry: nil },

  { item: "FAB-GRY-POP",  wh: wh_grey,     batch: "GRY/25-26/0087", qty: 5200, cost: 62.00,  expiry: nil },
  { item: "FAB-GRY-TWL",  wh: wh_grey,     batch: "GRY/25-26/0091", qty: 3600, cost: 74.50,  expiry: nil },

  { item: "FAB-DYE-NVY",  wh: wh_finished, batch: "FIN/25-26/0203", qty: 1800, cost: 118.00, expiry: nil },
  { item: "FAB-DYE-MRN",  wh: wh_finished, batch: "FIN/25-26/0204", qty: 1550, cost: 121.50, expiry: nil },
  { item: "FAB-PRT-FLR",  wh: wh_finished, batch: "FIN/25-26/0217", qty: 640,  cost: 156.00, expiry: nil },

  { item: "DYE-RCT-RED",  wh: wh_dye,      batch: "CHM/25-26/0033", qty: 320,  cost: 410.00, expiry: Date.new(2027, 3, 31) },
  { item: "DYE-RCT-BLK",  wh: wh_dye,      batch: "CHM/25-26/0034", qty: 285,  cost: 395.00, expiry: Date.new(2027, 3, 31) },
  { item: "CHM-CAU-FLK",  wh: wh_dye,      batch: "CHM/25-26/0041", qty: 900,  cost: 38.00,  expiry: Date.new(2028, 1, 31) },
  { item: "CHM-SOD-ASH",  wh: wh_dye,      batch: "CHM/25-26/0042", qty: 850,  cost: 29.50,  expiry: Date.new(2028, 1, 31) },
  { item: "CHM-H2O2-50",  wh: wh_dye,      batch: "CHM/25-26/0055", qty: 410,  cost: 52.00,  expiry: Date.new(2026, 12, 31) },

  { item: "TRM-BTN-4H",   wh: wh_raw,      batch: "TRM/25-26/0012", qty: 48000, cost: 0.35,  expiry: nil },
  { item: "TRM-ZIP-N5",   wh: wh_raw,      batch: "TRM/25-26/0013", qty: 12000, cost: 4.20,  expiry: nil },

  { item: "FG-SHIRT-M",   wh: wh_finished, batch: "FG/25-26/0009",  qty: 860,  cost: 285.00, expiry: nil }
]

batches = inventory_batches_data.map do |b|
  InventoryBatch.find_or_create_by!(batch_number: b[:batch]) do |rec|
    rec.item = items.fetch(b[:item])
    rec.warehouse = b[:wh]
    rec.quantity = b[:qty]
    rec.unit_cost = b[:cost]
    rec.expiry_date = b[:expiry]
  end
end
puts "Inventory Batches: #{batches.size}"

# ---------------------------------------------------------------------------
# Job Work Challans + Job Work Items
# Models material sent out for weaving/dyeing/printing/stitching and what
# came back, so partial-return and scrap scenarios are represented.
# ---------------------------------------------------------------------------
challans_data = [
  {
    worker: jw_weaving, issued: 18.days.ago, expected: 4.days.ago, status: "Completed",
    lines: [{ item: "YRN-CTN-30S", issued_qty: 2000, received_qty: 1940, scrapped_qty: 60 }]
  },
  {
    worker: jw_dyeing, issued: 10.days.ago, expected: 3.days.ago, status: "Completed",
    lines: [
      { item: "FAB-GRY-POP", issued_qty: 1200, received_qty: 1180, scrapped_qty: 20 },
      { item: "DYE-RCT-RED", issued_qty: 45,   received_qty: 0,    scrapped_qty: 0 }
    ]
  },
  {
    worker: jw_printing, issued: 6.days.ago, expected: 1.day.from_now, status: "Pending",
    lines: [{ item: "FAB-GRY-TWL", issued_qty: 700, received_qty: 0, scrapped_qty: 0 }]
  },
  {
    worker: jw_finishing, issued: 2.days.ago, expected: 5.days.from_now, status: "Pending",
    lines: [{ item: "FAB-DYE-NVY", issued_qty: 500, received_qty: 0, scrapped_qty: 0 }]
  },
  {
    worker: jw_stitching, issued: 25.days.ago, expected: 11.days.ago, status: "Overdue",
    lines: [{ item: "FAB-DYE-MRN", issued_qty: 300, received_qty: 210, scrapped_qty: 15 }]
  }
]

challan_count = 0
line_count = 0

challans_data.each do |c|
  challan = JobWorkChallan.find_or_create_by!(job_worker: c[:worker], issued_date: c[:issued]) do |rec|
    rec.expected_return_date = c[:expected]
    rec.status = c[:status]
  end
  challan_count += 1

  c[:lines].each do |line|
    JobWorkItem.find_or_create_by!(job_work_challan: challan, item: items.fetch(line[:item])) do |rec|
      rec.quantity_issued = line[:issued_qty]
      rec.quantity_received = line[:received_qty]
      rec.quantity_scrapped = line[:scrapped_qty]
    end
    line_count += 1
  end
end
puts "Job Work Challans: #{challan_count} (#{line_count} line items)"

# ---------------------------------------------------------------------------
# Quality Inspections — checks performed against both inventory batches (raw
# material GRN) and job work challans (post-processing) using the
# polymorphic source_type/source_id pair
# ---------------------------------------------------------------------------
grey_poplin_batch = batches.find { |b| b.batch_number == "GRY/25-26/0087" }
dyed_navy_batch   = batches.find { |b| b.batch_number == "FIN/25-26/0203" }
weaving_challan    = JobWorkChallan.find_by(job_worker: jw_weaving)
stitching_challan  = JobWorkChallan.find_by(job_worker: jw_stitching)

inspections_data = [
  { source_type: "InventoryBatch",   source: grey_poplin_batch,  item: "FAB-GRY-POP", inspected: 1200, approved: 1150, rejected: 50,  status: "Passed" },
  { source_type: "InventoryBatch",   source: dyed_navy_batch,    item: "FAB-DYE-NVY", inspected: 1800, approved: 1760, rejected: 40,  status: "Passed" },
  { source_type: "JobWorkChallan",   source: weaving_challan,    item: "YRN-CTN-30S", inspected: 1940, approved: 1900, rejected: 40,  status: "Passed" },
  { source_type: "JobWorkChallan",   source: stitching_challan,  item: "FAB-DYE-MRN", inspected: 210,  approved: 180,  rejected: 30,  status: "Failed" }
]

inspections_data.each do |q|
  next unless q[:source]

  QualityInspection.find_or_create_by!(source_type: q[:source_type], source_id: q[:source].id, item: items.fetch(q[:item])) do |rec|
    rec.quantity_inspected = q[:inspected]
    rec.quantity_approved = q[:approved]
    rec.quantity_rejected = q[:rejected]
    rec.inspected_by = admin.id
    rec.status = q[:status]
  end
end
puts "Quality Inspections: #{inspections_data.count { |q| q[:source] }}"

# ---------------------------------------------------------------------------
# Wastage Logs — material lost to cutting loss, process loss, damage, shrinkage
# ---------------------------------------------------------------------------
wastage_data = [
  { item: "FAB-DYE-NVY", qty: 22, reason: "CUTTING_LOSS",  cost: 2596.00, logged: 3.days.ago },
  { item: "FAB-GRY-POP", qty: 20, reason: "PROCESS_LOSS",  cost: 1240.00, logged: 8.days.ago },
  { item: "FAB-DYE-MRN", qty: 15, reason: "DAMAGE",        cost: 1822.50, logged: 12.days.ago },
  { item: "YRN-CTN-30S", qty: 60, reason: "PROCESS_LOSS",  cost: 14700.00, logged: 17.days.ago },
  { item: "FAB-PRT-FLR", qty: 8,  reason: "SHRINKAGE",     cost: 1248.00, logged: 1.day.ago }
]

wastage_data.each do |w|
  WastageLog.find_or_create_by!(item: items.fetch(w[:item]), logged_at: w[:logged], reason_code: w[:reason]) do |rec|
    rec.quantity_wasted = w[:qty]
    rec.estimated_cost = w[:cost]
  end
end
puts "Wastage Logs: #{wastage_data.size}"

puts "== Seeding complete =="