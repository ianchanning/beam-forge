# INTENT: REFACTOR CALCULATOR TO FUNCTIONAL STYLE

**GOAL:** Refactor the `Calculator` class in `src/calc.ts` to use pure functions and immutability.

**ACCEPTANCE CRITERIA:**
1.  All class methods (`add`, `subtract`, `multiply`, `divide`) must be converted to exported pure functions.
2.  No state should be stored in the module.
3.  Unit tests must pass.
4.  Edge cases (e.g., division by zero) must be handled gracefully.

**RESOURCES:**
- `src/calc.ts`
- `tests/calc.test.ts`
