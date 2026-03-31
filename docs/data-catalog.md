### Data Dictionary for Gold Layer
---

## Overview

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics. 

---

## 1. Gold.dim_customers
*  Purpose: Stores customers details enriched with demographic and geographic data 

| Column Name | Data Type| Description |
|---|---|---|
| Customer_key | INT | Surrogate key uniquely identifying each customer record in the dimension tables |
| Customer_id | INT | Unique numerical identifier attached to each customer |
