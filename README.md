# Olist E-Commerce ERP & Analytics Database Architecture

A production-grade, 5-layer relational database architecture built on top of the Brazilian E-Commerce Public Dataset (Olist). 

This project goes beyond basic SQL queries by implementing a robust backend infrastructure designed for high performance, data integrity, and scalable business operations. The architecture is directly driven by real-world e-commerce domain expertise. Business rules such as exact cancellation limits, partial refund processing, and automated payment auditing are handled securely at the database level.

## 📊 Dataset Information
**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/olistbr/brazilian-ecommerce)

This is a Brazilian ecommerce public dataset of orders made at Olist Store. The dataset contains information on 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allow viewing an order from multiple dimensions: from order status, price, payment, and freight performance to customer location, product attributes, and reviews. 

*(Note: This is real commercial data that has been anonymised by Olist.)*

## 🗂️ Database Schema (ER Diagram)
![Olist Database Schema](https://i.imgur.com/HRhd2Y0.png)

## 🏗️ 5-Layer Modular Architecture

1. **Operational Layer (Stored Procedures):** Handles transactional operations with strict ACID compliance (e.g., `sp_CancelOrderFullRefund`, `sp_ProcessPartialRefund`).
2. **Calculation Layer (Scalar Functions):** Pure, state-independent functions for high-performance business logic calculations (e.g., `fn_CalculateLateDeliveryPenalty`).
3. **Audit Layer (Triggers):** Automated defensive programming and logging mechanisms (e.g., `trg_PreventNegativePayment`, `trg_LogPaymentValueChange`).
4. **Performance Layer (Indexes):** Strategic indexing for read-heavy operations and time-series filtering.
5. **Reporting Layer (Views):** Advanced analytical structures using Window Functions and CTEs for customer segmentation, order frequency, and route performance.

## 🚀 Tech Stack
* **Database:** MySQL 
* **Techniques:** Procedural SQL (Triggers, Functions, Procedures), Advanced Querying (CTEs, Window Functions), Defensive SQL (Signal/Resignal)

## 🗺️ Future Roadmap
* **Backend Integration:** Developing a modular C# .NET API to interface with this database structure, focusing on clean architecture and data access repositories.
