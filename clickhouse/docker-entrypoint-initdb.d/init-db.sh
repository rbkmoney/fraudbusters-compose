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

    DROP TABLE IF EXISTS fraud.withdrawal;

    create table fraud.withdrawal
    (
        timestamp             Date,
        eventTime             UInt64,
        eventTimeHour         UInt64,

        id                    String,

        amount                UInt64,
        currency              String,

        bin                   String,
        maskedPan             String,
        cardToken             String,
        paymentSystem         String,
        paymentTool           String,
        bankName              String,
        cardHolderName        String,
        issuerCountry         String,

        cryptoWalletId        String,
        cryptoWalletCurrency  String,

        terminal              String,
        providerId            String,
        bankCountry           String,

        identityId            String,
        accountId             String,
        accountCurrency       String,

        status                Enum8('pending' = 1, 'succeeded' = 2, 'failed' = 3),
        errorReason           String,
        errorCode             String

    ) ENGINE = ReplacingMergeTree()
    PARTITION BY toYYYYMM (timestamp)
    ORDER BY (eventTimeHour, identityId, status, currency, paymentSystem, providerId, cardToken, id);

    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'processed', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'captured', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'group_1','2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'processed', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'group_1','2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'captured', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'partyId_2','2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'processed', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2020-05-06', 1588761208,1588759200000, 'partyId_2','2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'captured', '','1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'processed', '','1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'captured', '','1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'processed', '','1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'captured', '','1DkratTwbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'captured', '','1DkratTrpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'captured', '','1DkratTwbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');
    INSERT INTO fraud.payment (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount,
    currency, status, errorReason, id, ip, bin, maskedPan, paymentTool, cardToken)
    VALUES
    ('2019-12-05', 1587761208,1587759200000, 'group_1','2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'captured', '','1Dkragfbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05');

    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
    ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'rejected', '1DkraVdGJbs.1', '204.26.61.110', '666', '3125', 'bank_card','477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbd');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'rejected', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card','477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vba');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'rejected', '1VMI0gIoAy0.2', '204.26.61.110', '666', '3125', 'bank_card','477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbc');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'cancelled', '1VMI3GwdR5s.1', '204.26.61.110', '666', '3125', 'bank_card',        '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbf');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'accepted', '1DkraVdGJfr.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbe');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035729', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'accepted', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbp');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'cancelled', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbdss');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'cancelled', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbz');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'accepted', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbuc');
    INSERT INTO fraud.chargeback
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'rejected', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '1111vbtt');

    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'captured', '1DkraVdGJbs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'captured', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b',  50000, 'RUB', 'captured', '1VMI0gIoAy0.2', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', 'comment');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'cancelled', '1VMI3GwdR5s.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'processed', '1DkraVdGJfr.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035729', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'processed', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'processed', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', 'comment');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'cancelled', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'pending', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');
    INSERT INTO fraud.fraud_payment
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, fraudType, comment)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'partyId_2', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'failed', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'fraud', '');

    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES ('2020-06-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 1, '2PkraBdGJbs.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT', '', 'RULE_NOT_CHECKED', 'RUS', '1111vbd', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 1, '1DkraVdGJbs.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT', '', 'RULE_NOT_CHECKED', 'RUS', '1111vbd', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 0, '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT', '', 'RULE_NOT_CHECKED', 'RUS', '1111vba', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 1, '1VMI0gIoAy0.2', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT', '', 'RULE_NOT_CHECKED', 'RUS', '1111vbc', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 1, '1VMI3GwdR5s.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT', '3DS_RULE', '3DS_TEMPLATE', 'RUS', '1111vbf', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 1, '1DkraVdGJfr.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT_AND_NOTIFY', 'count', 'COUNT_TEMPLATE', 'RUS', '1111vbe', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035729', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 0, '1DkraVdGJfb.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'ACCEPT_AND_NOTIFY', 'sum', 'SUM_TEMPLATE', 'RUS', '1111vbp', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 0, '1DkratTHbpg.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'NORMAL', '', 'RULE_NOT_CHECKED', 'RUS', '1111vbdss', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 1, '1DkratTHbpg.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'NORMAL', '', 'RULE_NOT_CHECKED', 'RUS', '1111vbz', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'EUR', 0, '1DkratTHbpg.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'NORMAL', 'COUNTRY_RULE', 'COUNTRY_TEMPLATE', 'NED', '1111vbuc', 'SBER');
    INSERT INTO fraud.events_unique
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, mobile, paymentId,
     ip, bin, maskedPan, cardToken, resultStatus, checkedRule, checkedTemplate, bankCountry, invoiceId, bankName)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 0, '1DkratTHbpg.1', '204.26.61.110', '666', '3125', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'NOTIFY', '3DS', '3DS_TEMPLATE', 'RUS', '1111vbtt', 'SBER');

    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'succeeded', '', '1DkraVdGJbs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbd');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 10500, 'RUB', 'failed', '', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vba');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'succeeded', '', '1VMI0gIoAy0.2', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbc');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'group_1', '2035728', 'email_2', '5bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'failed', '', '1VMI3GwdR5s.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbf');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035728', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'succeeded', '', '1DkraVdGJfr.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbe');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2020-05-06', 1588761208, 1588759200000, 'partyId_2', '2035729', 'email_2', '4bef59146f8e4640ab34915f84ddac8b', 50000, 'RUB', 'succeeded', '', '1DkraVdGJfs.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbdxx');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'succeeded', '', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbdss');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'succeeded', '', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbz');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'failed', '', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', '', '1111vbdsuy');
    INSERT INTO fraud.refund
    (timestamp, eventTime, eventTimeHour, partyId, shopId, email, fingerprint, amount, currency, status, errorReason, id,
     ip, bin, maskedPan, paymentTool, cardToken, paymentSystem, terminal, providerId, bankCountry, errorCode, paymentId)
    VALUES
    ('2019-12-05', 1587761208, 1587759200000, 'group_1', '2035728', 'email', '4bef59146f8e4640ab34915f84ddac8b', 5000, 'RUB', 'failed', '666', '1DkratTHbpg.1', '204.26.61.110', '666', '3125', 'bank_card', '477bba133c182267fe5f086924abdc5db71f77bfc27f01f2843f2cdc69d89f05', 'VISA', '123', '1', 'RUS', 'Error', '1111vbtt');

EOSQL
