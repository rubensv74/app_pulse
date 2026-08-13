# C17-D-FIX1 — Custom Field renderer safety

Pending Studio validation.

Findings from the Studio source dated 2026-08-13:

1. `galCFVPro_Values.OnSelect` currently resets the working collection and dirty state. Remove that behavior; cancellation must remain explicit through the Cancel button.
2. `cmbCFVPro_Choice` is now `ModernCombobox@1.1.1`, but its current source does not declare the same read-only/edit policy used by the other renderers. Add the same DisplayMode policy based on CanEdit, IsEditable, IsLoading and IsSaving.
3. Declare search behavior explicitly for the modern ComboBox instead of relying on defaults.

Validation: clicks on gallery whitespace must not discard unsaved edits; reader mode must keep Choice/MultiChoice read-only; manager mode must remain editable; Save, Cancel and dirty state must remain unchanged.