USE BitSharp
GO

IF OBJECT_ID('BlockHeaders') IS NULL
CREATE TABLE BlockHeaders
(
	BlockHash BINARY(32) NOT NULL,
	HeaderBytes BINARY(80) NOT NULL,
	CONSTRAINT PK_Blocks PRIMARY KEY NONCLUSTERED
	(
		BlockHash
	)
);

IF OBJECT_ID('ChainedBlocks') IS NULL
CREATE TABLE ChainedBlocks
(
	BlockHash BINARY(32) NOT NULL,
	PreviousBlockHash BINARY(32) NOT NULL,
	Height INTEGER NOT NULL,
	TotalWork BINARY(64) NOT NULL,
	CONSTRAINT PK_ChainedBlocks PRIMARY KEY NONCLUSTERED
	(
		BlockHash
	)
);

IF OBJECT_ID('KnownAddresses') IS NULL
CREATE TABLE KnownAddresses
(
	IPAddress BINARY(16) NOT NULL,
	Port BINARY(2) NOT NULL,
	Services BINARY(8) NOT NULL,
	"Time" BINARY(4) NOT NULL,
	CONSTRAINT PK_KnownAddresses PRIMARY KEY
	(
		IPAddress,
		Port
	)
);

IF OBJECT_ID('BlockTransactions') IS NULL
CREATE TABLE BlockTransactions
(
	BlockHash BINARY(32) NOT NULL,
	TxIndex INTEGER NOT NULL,
	TxHash BINARY(32) NOT NULL,
	TxBytes VARBINARY(MAX) NOT NULL,
	CONSTRAINT PK_TransactionLocators PRIMARY KEY NONCLUSTERED
	(
		BlockHash,
		TxIndex
	) WITH ( IGNORE_DUP_KEY = ON )
);

IF NOT EXISTS(SELECT * FROM sysindexes WHERE name = 'IX_BlockTransactions_BlockHash')
CREATE NONCLUSTERED INDEX IX_BlockTransactions_BlockHash ON BlockTransactions ( BlockHash );

IF NOT EXISTS(SELECT * FROM sysindexes WHERE name = 'IX_BlockTransactions_TxHash')
CREATE NONCLUSTERED INDEX IX_BlockTransactions_TxHash ON BlockTransactions ( TxHash );

IF OBJECT_ID('BlockTransactionsChunked') IS NULL
CREATE TABLE BlockTransactionsChunked
(
	BlockHash BINARY(32) NOT NULL,
	MinTxIndex INTEGER NOT NULL,
	MaxTxIndex INTEGER NOT NULL,
	TxChunkBytes VARBINARY(MAX) NOT NULL,
	CONSTRAINT PK_BlockTransactionsChunked PRIMARY KEY NONCLUSTERED
	(
		BlockHash,
		MinTxIndex
	),
	CONSTRAINT UQ_BlockTransactionsChunked_MaxTxIndex UNIQUE ( BlockHash, MaxTxIndex )
);

--IF NOT EXISTS(SELECT * FROM sysindexes WHERE name = 'IX_BlockTransactionsChunked_BlockHash')
--CREATE NONCLUSTERED INDEX IX_BlockTransactionsChunked_BlockHash ON BlockTransactionsChunked ( BlockHash );
