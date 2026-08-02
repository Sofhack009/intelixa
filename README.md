# Intelixa

Intelixa is a Rails operations dashboard for inventory, warehouses, job work challans, quality inspections, and wastage tracking. The signed-in dashboard summarizes operational health while Motor Admin provides administrative CRUD screens for trusted administrators.

## Requirements

- Ruby 3.4.x
- Rails 8.0.x
- PostgreSQL
- Bundler

## Setup

```bash
bundle install
bin/rails db:prepare
```

Create an administrator by setting a user's `role` to `admin`; ordinary signed-in users remain `operator` users and cannot access Motor Admin.

## Development

```bash
bin/dev
```

Visit `/dashboard` for the operations dashboard. Admin users can visit `/motor_admin` for back-office resource management.

## Testing and security checks

```bash
bin/rails test
bin/brakeman --no-pager
```

The GitHub Actions workflow runs database preparation, Rails tests, and Brakeman on pushes and pull requests.
