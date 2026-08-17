/*
    RETRACTED — DO NOT RUN

    This test incorrectly used the visible ProjectCode (70200) as the SQL ProjectId.

    In PULSE:
    - ProjectCode visible to users: 70200
    - Internal SQL ProjectId for this project: 4049

    Use instead:

    sql/export/tests/PR-EXP-C03B1_validate_scope_projectcode70200_internal4049_template20.sql
*/

THROW 52999, 'RETRACTED TEST. Use the corrected PR-EXP-C03B1 test with internal ProjectId 4049.', 1;
