
CREATE PROCEDURE sp_UpdateSubjectAllotment
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Loop through each request in SubjectRequest table
    DECLARE @StudentID VARCHAR(50)
    DECLARE @RequestedSubjectID VARCHAR(50)
    DECLARE @CurrentSubjectID VARCHAR(50)

    DECLARE request_cursor CURSOR FOR
    SELECT StudentId, SubjectId FROM SubjectRequest

    OPEN request_cursor
    FETCH NEXT FROM request_cursor INTO @StudentID, @RequestedSubjectID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if student already has a valid subject
        SELECT @CurrentSubjectID = SubjectId
        FROM SubjectAllotments
        WHERE StudentId = @StudentID AND Is_valid = 1

        IF @CurrentSubjectID IS NULL
        BEGIN
            -- Case 1: Student not found in SubjectAllotments → Insert new valid record
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid)
            VALUES (@StudentID, @RequestedSubjectID, 1)
        END
        ELSE IF @CurrentSubjectID <> @RequestedSubjectID
        BEGIN
            -- Case 2: Student exists and requested subject is different
            -- 1. Make current valid subject invalid
            UPDATE SubjectAllotments
            SET Is_valid = 0
            WHERE StudentId = @StudentID AND Is_valid = 1

            -- 2. Insert new requested subject as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid)
            VALUES (@StudentID, @RequestedSubjectID, 1)
        END
        -- Else: Requested subject is already the current one → Do nothing

        FETCH NEXT FROM request_cursor INTO @StudentID, @RequestedSubjectID
    END

    CLOSE request_cursor
    DEALLOCATE request_cursor

    -- Optional: Clear SubjectRequest table if processed
    -- DELETE FROM SubjectRequest
END
