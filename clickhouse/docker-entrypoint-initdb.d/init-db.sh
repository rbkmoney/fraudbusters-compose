#!/bin/bash
set -e

CLICKHOUSE_USER="${CLICKHOUSE_USER:-user}";
CLICKHOUSE_PASSWORD="${CLICKHOUSE_PASSWORD:-password}";

cat <<EOT >> /etc/clickhouse-server/users.d/user.xml
<yandex>
  <!-- Docs: <https://clickhouse.tech/docs/en/operations/settings/settings_users/> -->
  <users>
    <${CLICKHOUSE_USER}>
      <profile>default</profile>
      <networks>
        <ip>::/0</ip>
      </networks>
      <password>${CLICKHOUSE_PASSWORD}</password>
      <quota>default</quota>
    </${CLICKHOUSE_USER}>
  </users>
</yandex>
EOT

clickhouse client -n <<-EOSQL
    CREATE DATABASE IF NOT EXISTS fraud;

    DROP TABLE IF EXISTS fraud.events_unique;

    create table fraud.events_unique (
      timestamp Date,
      eventTimeHour UInt64,
      eventTime UInt64,

      partyId String,
      shopId String,

      ip String,
      email String,
      bin String,
      fingerprint String,
      resultStatus String,
      amount UInt64,
      country String,
      checkedRule String,
      bankCountry String,
      currency String,
      invoiceId String,
      maskedPan String,
      bankName String,
      cardToken String,
      paymentId String,
      checkedTemplate String
    ) ENGINE = MergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, bin, resultStatus, cardToken, email, ip, fingerprint)
    TTL timestamp + INTERVAL 3 MONTH;

    DROP TABLE IF EXISTS fraud.events_p_to_p;

    create table fraud.events_p_to_p (
      timestamp Date,
      eventTime UInt64,
      eventTimeHour UInt64,

      identityId String,
      transferId String,

      ip String,
      email String,
      bin String,
      fingerprint String,

      amount UInt64,
      currency String,

      country String,
      bankCountry String,
      maskedPan String,
      bankName String,
      cardTokenFrom String,
      cardTokenTo String,

      resultStatus String,
      checkedRule String,
      checkedTemplate String
    ) ENGINE = MergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (eventTimeHour, identityId, cardTokenFrom, cardTokenTo, bin, fingerprint, currency);

    CREATE DATABASE IF NOT EXISTS fraud;

    CREATE DATABASE IF NOT EXISTS fraud;

DROP TABLE IF EXISTS fraud.fraud_payment;

create table fraud.fraud_payment (

timestamp Date,
  id String,
  eventTime UInt64,
  eventTimeHour UInt64,

  fraudType String,
  comment String,

    email                 String,
    ip                    String,
    fingerprint           String,

    bin                   String,
    maskedPan             String,
    cardToken             String,
    paymentSystem         String,
    paymentTool           String,

    terminal              String,
    providerId            String,
    bankCountry           String,

    partyId               String,
    shopId                String,

    amount                UInt64,
    currency              String,

    status                Enum8('pending' = 1, 'processed' = 2, 'captured' = 3, 'cancelled' = 4, 'failed' = 5),
    errorReason           String,
    errorCode             String,
    paymentCountry        String
) ENGINE = MergeTree()
PARTITION BY toYYYYMM (timestamp)
ORDER BY (eventTimeHour, partyId, shopId, paymentTool, status, currency, providerId, fingerprint, cardToken, eventTime, id);


    DROP TABLE IF EXISTS fraud.refund;

    create table fraud.refund
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('pending' = 1, 'succeeded' = 2, 'failed' = 3),
        errorReason           String,
        errorCode             String,
        paymentId             String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, status, currency, providerId, fingerprint, cardToken, id, paymentId);

    DROP TABLE IF EXISTS fraud.payment;

    create table fraud.payment
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('pending' = 1, 'processed' = 2, 'captured' = 3, 'cancelled' = 4, 'failed' = 5),
        errorReason           String,
        errorCode             String,
        paymentCountry        String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, paymentTool, status, currency, providerId, fingerprint, cardToken, id);

    DROP TABLE IF EXISTS fraud.chargeback;

    create table fraud.chargeback
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('accepted' = 1, 'rejected' = 2, 'cancelled' = 3),

        category              Enum8('fraud' = 1, 'dispute' = 2, 'authorisation' = 3, 'processing_error' = 4),
        chargebackCode        String,
        paymentId             String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, category, status, currency, providerId, fingerprint, cardToken, id, paymentId);

    DROP TABLE IF EXISTS fraud.refund;

    create table fraud.refund
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('pending' = 1, 'succeeded' = 2, 'failed' = 3),
        errorReason           String,
        errorCode             String,
        paymentId             String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, status, currency, providerId, fingerprint, cardToken, id, paymentId);

    DROP TABLE IF EXISTS fraud.payment;

    create table fraud.payment
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('pending' = 1, 'processed' = 2, 'captured' = 3, 'cancelled' = 4, 'failed' = 5),
        errorReason           String,
        errorCode             String,
        paymentCountry        String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, paymentTool, status, currency, providerId, fingerprint, cardToken, id);

    DROP TABLE IF EXISTS fraud.chargeback;

    create table fraud.chargeback
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        email                 String,
        ip                    String,
        fingerprint           String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        partyId               String,
        shopId                String,

        amount                UInt64,
        currency              String,

        status                Enum8('accepted' = 1, 'rejected' = 2, 'cancelled' = 3),

        category              Enum8('fraud' = 1, 'dispute' = 2, 'authorisation' = 3, 'processing_error' = 4),
        chargebackCode        String,
        paymentId             String
    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, partyId, shopId, category, status, currency, providerId, fingerprint, cardToken, id, paymentId);

    ALTER TABLE fraud.events_unique ADD COLUMN payerType String;
    ALTER TABLE fraud.events_unique ADD COLUMN tokenProvider String;

    ALTER TABLE fraud.payment ADD COLUMN payerType String;
    ALTER TABLE fraud.payment ADD COLUMN tokenProvider String;

    ALTER TABLE fraud.refund ADD COLUMN payerType String;
    ALTER TABLE fraud.refund ADD COLUMN tokenProvider String;

    ALTER TABLE fraud.chargeback ADD COLUMN payerType String;
    ALTER TABLE fraud.chargeback ADD COLUMN tokenProvider String;

    ALTER TABLE fraud.events_unique ADD COLUMN mobile UInt8;
    ALTER TABLE fraud.events_unique ADD COLUMN recurrent UInt8;

    ALTER TABLE fraud.payment ADD COLUMN mobile UInt8;
    ALTER TABLE fraud.payment ADD COLUMN recurrent UInt8;
EOSQL
