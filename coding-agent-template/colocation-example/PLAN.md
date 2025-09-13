# Phase 1 Dataset Recreation Plan: Pivot from Approval Analytics to Loan Defaults Analytics

## Context

Current setup in `scripts/phase-1` is designed for approval rate analytics with questions like:
- "What is the approval rate for personal loans in Q2 for various channels?"
- "How did Q2 approval rates change versus Q1?"

Need to pivot to loan defaults analytics for questions like:
- "How many customers have defaulted on their loans in the last 3 months?"
- "What drove the change in loan defaults versus the prior month?"

## Dataset Description

- aloan: Loan Accounts Information
- aloan_hist: Loan Accounts Historical Information
- rloan: Loan Repayment Schedule Information (NOT rejections as currently implemented)
- tloan: Loan Transactions Information

## Implementation Plan

- WORKING FOLDER: `scripts/phase-1`
- You have to connect Amazon RDS PostgreSQL through Amazon EC2 (see PROPOSAL.md, Low-level Architecture Components to understand). NEVER TEMPORARILY TURN ON RDS PUBLIC ACCESS!
- Use environment variables from `scripts/STEP_1_SET_ENVIRONMENT.sh` for AWS access

### Step 1: Update PostgreSQL Schema for Defaults Analytics

**File to Update**: `scripts/phase-1/step-1-postgres-views/02_create_schema_and_tables.sql`

**Changes Required**:
1. **Restructure aloan table**: Keep as loan accounts information with origination data
2. **Add aloan_hist table**: SCD2 for loan account historical changes (restructures, rate changes)
3. **Replace current rloan (rejections) with rloan (repayment schedule)**:
   - schedule_id, loan_account_id, installment_number, due_date, due_principal, due_interest, due_fees, total_due
4. **Update tloan for loan transactions**:
   - txn_id, loan_account_id, txn_date, amount, txn_type (payment, fee, interest), external_ref
5. **Add default_policy table**: Product-specific default definitions
   - product_type, dpd_threshold (90 days), include_restructure, include_bankruptcy, cooloff_days
6. **Maintain TIMESTAMPTZ and audit columns** for incremental refresh

### Step 2: Create Loan Defaults Analytics Views

**File to Update**: `scripts/phase-1/step-1-postgres-views/01_create_views.sql`

**New Views Required**:
1. **fact_loan_performance_monthly**: Monthly loan status snapshots
   - loan_account_id, as_of_month, outstanding_principal, past_due_amount, dpd, dpd_bucket, status
2. **fact_default_event**: First default events per loan
   - loan_account_id, default_date, trigger_type, exposure_at_default, dpd_at_default, vintage, product_type, channel
3. **vw_defaults_monthly_summary**: Monthly defaults aggregation for QuickSight
   - Support "How many defaulted in last 3 months" questions
4. **vw_defaults_mom_attribution**: Month-over-month change attribution
   - Support "What drove the change versus prior month" questions

**Key Metrics**:
- defaults (count), default_rate, active_loans, balance_at_default
- dpd_bucket distribution, roll_rates, cure_rates
- Volume/Rate/Mix attribution for MoM changes

### Step 3: Update Sample Data for Realistic Default Scenarios

**Sample Data Structure**:
1. **aloan**: 50+ loan accounts with various channels (FSA, Atome, Foodpanda)
2. **rloan**: Monthly repayment schedules for each loan
3. **tloan**: Payment transactions including missed payments leading to defaults
4. **Default scenarios**: 
   - 90+ days past due defaults
   - Various vintage (origination months) for trend analysis
   - Channel distribution for driver analysis

### Step 4: Update QuickSight Dataset Configuration

**File to Update**: `scripts/phase-1/step-2-quicksight-connection/CREATE_INCREMENTAL_DATASET.sh`

**Changes Required**:
1. Point to new defaults analytics views
2. Update dataset schema for defaults metrics
3. Maintain incremental refresh using updated_at columns
4. Update SQL queries to use vw_defaults_monthly_summary

### Step 5: Update Semantic Layer for Defaults Terminology

**File to Update**: `scripts/phase-1/step-3-semantic-layer/create_topic.sh`

**Changes Required**:
1. **Update named entities**: Default Events, Repayment Status, Delinquency Buckets, Default Drivers
2. **Update synonyms**:
   - Default: "non-performing", "delinquent", "past due", "NPL"
   - DPD: "days past due", "overdue days", "delinquency"
   - Bucket: "stage", "category", "band"
   - Change: "trend", "variance", "month over month", "MoM"

### Step 6: Update Master Deployment Script

**File to Update**: `scripts/phase-1/DEPLOY_PHASE1.sh`

**Changes Required**:
1. Update deployment sequence for new schema
2. Add validation for defaults data completeness
3. Update sample queries for testing defaults analytics
4. Maintain security validation (private RDS, VPC connections)

## Default Definition Strategy

Use policy-driven approach with 90+ days past due threshold:
- Primary trigger: DPD >= 90 days
- Optional triggers: Bankruptcy flag, restructure with economic loss
- Cooloff period: 30 days to avoid oscillations
- First default date per loan using earliest qualifying event

## Key Success Metrics

1. Support target questions:
   - "How many customers defaulted in last 3 months?" -> Count from fact_default_event
   - "What drove change versus prior month?" -> Volume/Rate/Mix attribution view

2. Maintain technical requirements:
   - TIMESTAMPTZ columns for incremental refresh
   - 15-minute refresh schedule
   - Private RDS with VPC connections
   - Security compliance validation

3. Business intelligence capabilities:
   - Monthly defaults trending
   - Channel-based default rate analysis
   - Vintage analysis (origination cohorts)
   - Delinquency roll rate matrices
