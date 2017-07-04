-- =============================================
-- Author:		Bert McKay
-- Create date: 4th July 2017
-- Description:	Generate a NINO within SQL, useful if you need to generate mock test data
-- =============================================

DECLARE @Values1 INT ,
        @Values2 INT ,
        @Values3 INT ,
        @ValueID INT ,
        @String1 CHAR(1) ,
        @String2 CHAR(1) ,
        @Prefix CHAR(2) ,
        @Number1 INT ,
        @Number2 INT ,
        @Number3 INT ,
        @Suffix CHAR(1);

SELECT @Values1 = COUNT(*)
FROM   dbo.SplitString('A,B,C,E,G,H,J,K,L,M,N,O,P,R,S,T,W,X,Y,Z', ',');
SELECT @Values2 = COUNT(*)
FROM   dbo.SplitString('A,B,C,E,G,H,J,K,L,M,N,P,R,S,T,W,X,Y,Z', ',');
SELECT @Values3 = COUNT(*)
FROM   dbo.SplitString('A,B,C,D', ',');

WHILE ISNULL(@Prefix, '') IN ( 'GB', 'BG', 'NK', 'KN', 'TN', 'NT', 'ZZ', '' )
    BEGIN
        SELECT @ValueID = ABS(CHECKSUM(NEWID())) % @Values1;

        WHILE @String1 IS NULL
            BEGIN
                SELECT @String1 = prefix1
                FROM   (   SELECT ROW_NUMBER() OVER ( ORDER BY splitdata ) rowid ,
                                  splitdata prefix1
                           FROM   dbo.SplitString(
                                                     'A,B,C,E,G,H,J,K,L,M,N,O,P,R,S,T,W,X,Y,Z' ,
                                                     ','
                                                 )
                       ) x
                WHERE  rowid = @ValueID;
            END;

        SELECT @ValueID = ABS(CHECKSUM(NEWID())) % @Values2;

        WHILE @String2 IS NULL
            BEGIN
                SELECT @String2 = prefix2
                FROM   (   SELECT ROW_NUMBER() OVER ( ORDER BY splitdata ) rowid ,
                                  splitdata prefix2
                           FROM   dbo.SplitString(
                                                     'A,B,C,E,G,H,J,K,L,M,N,P,R,S,T,W,X,Y,Z' ,
                                                     ','
                                                 )
                       ) x
                WHERE  rowid = @ValueID;
            END;

        SELECT @Prefix = CONCAT(@String1, @String2);
    END;

SELECT @Number1 = ABS(CHECKSUM(NEWID())) % 99;
SELECT @Number2 = ABS(CHECKSUM(NEWID())) % 99;
SELECT @Number3 = ABS(CHECKSUM(NEWID())) % 99;

SELECT @ValueID = ABS(CHECKSUM(NEWID())) % @Values3;
SELECT @Suffix = prefix3
FROM   (   SELECT ROW_NUMBER() OVER ( ORDER BY splitdata ) rowid ,
                  splitdata prefix3
           FROM   dbo.SplitString('A,B,C,D', ',')
       ) x
WHERE  rowid = @ValueID;

SELECT CONCAT(
                 @Prefix ,
                 ' ' ,
                 RIGHT('00' + CAST(@Number1 AS NVARCHAR(2)), 2),
                 ' ' ,
                 RIGHT('00' + CAST(@Number2 AS NVARCHAR(2)), 2),
                 ' ' ,
                 RIGHT('00' + CAST(@Number3 AS NVARCHAR(2)), 2),
                 ' ' ,
                 @Suffix
             );
