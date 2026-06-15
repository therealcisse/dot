---
name: scala-3-modern
description: Use when writing or refactoring any Scala 3 code, before implementing features that involve tuples, pattern matching, given instances, for-comprehensions, type parameters, or error handling with Cats/Cats Effect — teaches modern Scala 3.6/3.7/3.8 idioms and Cats Effect 3 error-handling combinators that simplify common patterns
---

# Modern Scala 3 — Idioms from 3.6, 3.7, and 3.8

This tutorial teaches six stable Scala 3 language features plus Cats/Cats Effect 3 error-handling combinators that together simplify everyday Scala. Each section shows the old way, the new way, and when to reach for the feature. Apply these proactively when they make code clearer.

## 1. Named Tuples (stable since 3.7)

Named tuples let you attach field names to tuples. Zero runtime overhead — names are erased.

### Before (3.3.4)

```scala
// Option A: ad-hoc case class just for a return type
case class PriceView(priceId: PriceId, amountMinor: Long, currency: Currency)
def listPrices: Future[List[PriceView]] = ...

// Option B: plain tuple, callers use ._1 ._2 ._3
def listPrices: Future[List[(PriceId, Long, Currency)]] = ...
prices.map { case (pid, amt, cur) => ... }  // pattern match to name things

// Option C: pattern match with _ for every unused field
case class Order(id: String, email: String, shippedAt: Option[OffsetDateTime], total: Long, tax: Long)
order match {
  case Order(_, _, Some(dt), t, _) => s"shipped at $dt for $$$t"  // _ _ _ everywhere
}
```

### After (3.7+)

```scala
// Named tuple as return type — no case class needed
def listPrices: Future[List[(priceId: PriceId, amountMinor: Long, currency: Currency)]] = ...
prices.map(_.priceId)  // access by name directly

// Type alias for reuse
type PriceRow = (priceId: PriceId, amountMinor: Long, currency: Currency)
def listPrices: Future[List[PriceRow]] = ...

// Named pattern matching on case classes — name only the fields you care about
order match {
  case Order(shippedAt = Some(dt), total = t) => s"shipped at $dt for $$$t"
  }
```

### When to use

- Return types with 2-4 fields where a case class feels like overhead
- Pattern matching on large case classes when you only need a few fields
- Intermediate values in a pipeline that need temporary names

### When NOT to use

- Domain entities that need identity, `copy`, or custom methods — keep those as case classes
- Types that appear in public APIs — case classes have stable `equals`/`hashCode` contracts

---

## 2. New Given Syntax (stable since 3.6)

SIP-64 replaces the verbose `given x: Type with` syntax with cleaner alternatives.

### Before (3.3.4)

```scala
// Alias given — already concise, largely unchanged
given DynamoFormat[PriceId] =
  DynamoFormat.xmap[PriceId, String](s => Right(PriceId(s)), _.value)

// Structural given with type parameter
given listOrd[T](using ord: Ord[T]): Ord[List[T]] with
  def compare(xs: List[T], ys: List[T]) = ...

// Abstract given in a trait
trait Repository[F[_]] {
  given DynamoFormat[Id]
}

// Unnamed context bound — can't refer to the witness
def maximum[T: Ord](xs: List[T]): T =
  xs.reduce(implicitly[Ord[T]].max)  // awkward

// Multiple bounds require nesting
def process[T: Monoid: Ord](x: T, y: T): T = ...
```

### After (3.6+)

```scala
// Alias given — unchanged
given DynamoFormat[PriceId] = DynamoFormat.xmap[PriceId, String](s => Right(PriceId(s)), _.value)

// Structural given — "is" replaces "with", parameters move before =>
given [T: Ord as ord] => List[T] is Ord {
  def compare(xs: List[T], ys: List[T]) = ...
}

// Deferred given — context bound on type member
trait Repository[F[_]] {
  type Id: DynamoFormat as format
}

// Named context bound — refer to the witness directly
def maximum[T: Ord as ord](xs: List[T]): T =
  xs.reduce(ord.max)

// Multiple bounds in braces
def process[T: {Monoid, Ord as ord}](x: T, y: T): T = ...

// Context bounds on polymorphic functions
type Comparer = [X: Ord] => (x: X, y: X) => Boolean
```

### Key rules

- **Alias given** (`given Type = expr`): unchanged
- **Structural given** (`given Type with { ... }`): becomes `given ... => ... is Type:`
- **Abstract given** (`given Type` in trait): becomes `type X: Type as name` on a type member
- **`as`** names a context bound so you can use the witness by name
- **`{...}`** groups multiple context bounds on a single type parameter

### When to use

- Every new given instance — old syntax still works but `is` is shorter
- Any time you write `implicitly[SomeType]` or `summon[SomeType]` — name the bound instead
- Traits that currently declare abstract givens — convert to type member bounds

---

## 3. Better Fors (stable since 3.8)

For-comprehensions can start with an assignment. Desugaring avoids redundant `map`/`flatMap` calls.

### Before (3.3.4)

```scala
// Must start with a generator, even a dummy one
for {
  _ <- List(())          // dummy generator just to enter the comprehension
  len = xs.length
  i <- 0 until len
} yield xs(i)

// Repeated computations in desugared chain
for {
  a <- computeA(x)
  b <- computeB(a)
} yield combine(a, b)
// desugars to: computeA(x).flatMap(a => computeB(a).map(b => combine(a, b)))
// computeB(a).map(...) creates an extra intermediate
```

### After (3.8)

```scala
// Start directly with an assignment
for {
  len = xs.length
  i <- 0 until len
} yield xs(i)

// Better desugaring — no redundant map when the last step is pure
for {
  a <- computeA(x)
  b <- computeB(a)
} yield combine(a, b)
// desugars to: computeA(x).flatMap(a => computeB(a).map(b => combine(a, b)))
// Same surface syntax, but the compiler elides the redundant .map when safe
```

### When to use

- Any for-comprehension that previously needed a dummy `_ <- SomeMonad` starter
- Code where you suspected redundant intermediate allocations in for-chains

---

## 4. Clause Interleaving (standard since 3.6)

Type parameter clauses can appear after term parameter clauses. Type bounds can depend on term values.

### Before (3.3.4)

```scala
// Type params always first, even when the user already knows the value type
def flatMap[A, B](fa: F[A])(f: A => F[B]): F[B] = ...

// Can't express: "the return type is exactly the argument type"
// Had to use match types or casts
def singletonOf[T](x: T): T = x  // loses precision — returns T, not x.type
```

### After (3.6+)

```scala
// Type param that depends on a term value
def singletonOf[T](x: T): x.type = x  // precise return type

// Term-dependent type bound
def replicate(x: Int)[T <: Singleton]: List[x.type] = List.fill(x)(x)

// Type params after the value they're inferred from
def map[F[_], A, B](fa: F[A])(f: A => B): F[B]  // still fine
def map[A](fa: F[A])[B](f: A => B): F[B]         // also fine — B comes after fa
```

### When to use

- When a type bound depends on a term value (e.g., singleton types)
- When placing type params after term params makes inference flow more naturally

---

## 5. runtimeChecked (stable since 3.8)

A cleaner way to suppress exhaustiveness checking than `@unchecked`.

### Before (3.3.4)

```scala
// Annotation on the scrutinee — syntactically awkward
(x: @unchecked) match {
  case P => ...
}

// Doesn't work for match type cases — annotations don't apply there
type AsInt[X] = X match {
  case Int => Int
  // can't mark String case as intentionally partial
}
```

### After (3.8)

```scala
// runtimeChecked wraps the scrutinee — reads naturally
runtimeChecked(x) match {
  case P => ...
}

// Also works in match type cases
type AsInt[X] = X match {
  case Int              => Int
  case runtimeChecked[String] => Int  // explicitly partial
}
```

### When to use

- When you know a match is partial and want to document that intent clearly
- In match type cases where you intentionally don't cover all possibilities
- Replaces ALL existing `@unchecked` annotations

---

## 6. Wildcard Types with `?` (since 3.4)

`_` for wildcard types is deprecated. Use `?` instead. This frees `_` to mean "type parameter placeholder" consistently.

### Before (3.3.4)

```scala
def process(xs: List[_]): Map[_ <: AnyRef, _ >: Null] = ???
```

### After (3.4+)

```scala
def process(xs: List[?]): Map[? <: AnyRef, ? >: Null] = ???
```

### Important exception

In match type case patterns, `_` is still correct — it binds a type variable, it's not a wildcard:

```scala
type Elem[X] = X match {
  case List[_] => ???  // _ binds the element type — keep it, don't use ?
}
```

### When to use

- Every wildcard type argument in method signatures, type aliases, and value definitions
- Run `-rewrite` under `-source 3.4` for automatic migration

---

## 7. Cats / Cats Effect Error Handling

This codebase uses cats-core 2.12+ and cats-effect 3.5+. `Sync[F]` extends `MonadThrow[F]`, so all combinators below work with the existing `Sync[F]` constraint.

The typeclass hierarchy: `ApplicativeError` → `MonadError` → `MonadThrow` (where `E` is fixed to `Throwable`). `Sync` extends `MonadThrow`.

### Raising errors

```scala
// Unconditionally
S.raiseError(CommerceError(ErrorCode.NotFound))

// Conditionally: fail if condition is TRUE — replaces if/else + raiseError
S.raiseWhen(tenant == null)(CommerceError(ErrorCode.TenantUnknown))

// Conditionally: fail if condition is FALSE — the "assert" form
S.raiseUnless(plan.status == EntityStatus.Active)(CommerceError(ErrorCode.PlanInactive))
```

### Guarding: conditionally run an effect

```scala
// Run effect only if condition is TRUE — replaces if (cond) effect else S.unit
S.whenA(plan.planType == PlanType.PaidSubscription) {
  loadPrices(tenant, plan.planId)
}

// Run effect only if condition is FALSE
S.unlessA(cacheHit) {
  fetchFromDb(id)
}
```

### Lifting Option and Either into F

```scala
// Option[A] → F[A]: None becomes the given error
// Before: opt.fold(S.raiseError(e))(S.pure)
opt.liftTo[F](CommerceError(ErrorCode.NotFound))

// Either[E, A] → F[A]: Left becomes the error (error type must match)
// Before: either.fold(S.raiseError, S.pure)
either.liftTo[F]
```

### Recovering from errors

```scala
// attempt: F[A] → F[Either[E, A]] — never fails, useful for inspection
action.attempt.map {
  case Right(value) => // success
  case Left(error)  => // inspect without handling
}

// handleError: recover with a pure fallback value (total function)
action.handleError {
  case _: CommerceError => defaultPrice
}

// handleErrorWith: recover with another effect (total function)
action.handleErrorWith {
  case CommerceError(ErrorCode.NotFound) => fallbackAction
  case other                            => S.raiseError(other) // re-raise unhandled
}

// recover / recoverWith: partial-function variants — unhandled errors propagate
action.recover {
  case CommerceError(ErrorCode.DataError) => defaultValue
}
action.recoverWith {
  case CommerceError(ErrorCode.DataError) => rebuildFromSource
}
```

**Choosing handleError vs recover:** Use `handleError`/`handleErrorWith` when you handle ALL errors (total function). Use `recover`/`recoverWith` when you only handle some (partial function) — unmatched errors propagate automatically without needing an explicit `case other => raiseError(other)` fallthrough.

```scala
// redeem: map both error and success in one call (total)
action.redeem(
  error => handleError(error),
  value => handleSuccess(value)
)

// redeemWith: both sides return effects
action.redeemWith(
  error => logError(error) >> fallbackAction,
  value => processValue(value)
)

// adaptErr: transform the error without handling it — error still propagates
action.adaptErr {
  case e: TimeoutException => CommerceError(ErrorCode.UpstreamTimeout)
}
```

### Lifecycle and side-effects

```scala
// onError: side-effect on error, does NOT recover — error still propagates
action.onError {
  case err => S.delay(span.setTag("error", true)).void
}

// guarantee: run finalizer on success, error, OR cancellation (like try/finally)
action.guarantee(S.delay(cleanup()))

// guaranteeCase: finalizer sees the exit reason
action.guaranteeCase {
  case Outcome.Succeeded(_) => S.delay(logger.info("ok"))
  case Outcome.Errored(e)   => S.delay(logger.error("failed", e))
  case Outcome.Canceled()   => S.delay(logger.warn("cancelled"))
}

// void: discard the value, keep the effect — F[A] → F[Unit]
S.delay(setTag("tenant", name)).void
```

### Decision tree

```
F[A] and need to...
│
├─ Create failure
│   ├─ Unconditionally        → raiseError(e)
│   ├─ If condition true      → raiseWhen(cond)(e)
│   └─ If condition false     → raiseUnless(cond)(e)
│
├─ Conditionally run (→ F[Unit])
│   ├─ If true                → whenA(cond)(effect)
│   └─ If false               → unlessA(cond)(effect)
│
├─ Convert Option/Either → F
│   ├─ Option[A]              → opt.liftTo[F](errorIfNone)
│   └─ Either[E, A]           → either.liftTo[F]
│
├─ Inspect both sides         → .attempt
├─ Replace error with value   → .handleError { case ... => fallback }
├─ Replace error with effect  → .handleErrorWith { case ... => fallbackF }
├─ Partial recovery (value)   → .recover { case ... => fallback }
├─ Partial recovery (effect)  → .recoverWith { case ... => fallbackF }
├─ Map both sides             → .redeem(err => ..., ok => ...)
├─ Transform the error        → .adaptErr { case e => Wrapped(e) }
├─ Side-effect on error       → .onError { case e => log(e) }
├─ Finalizer (always)         → .guarantee(cleanup)
└─ Discard value              → .void
```

---

## Cheatsheet

| I'm writing... | Old way | New way |
|----------------|---------|---------|
| A return type with a few fields | `case class V(a: A, b: B)` | `(a: A, b: B)` named tuple |
| Pattern match on a big case class | `case Foo(_, _, x, _, y, _) =>` | `case Foo(fieldX = x, fieldY = y) =>` |
| A structural given | `given foo: Type with { ... }` | `given ... => ... is Type:` |
| An abstract given in a trait | `given Type` | `type X: Type as name` |
| `implicitly[Ord[T]]` | `summon[Ord[T]].compare(a, b)` | `[T: Ord as ord]` then `ord.compare(a, b)` |
| A for-loop starting with assignment | `_ <- List(())` dummy generator | `len = xs.length` directly |
| `(x: @unchecked)` | annotation on scrutinee | `runtimeChecked(x)` |
| Wildcard type argument | `List[_]` | `List[?]` |
| Raise error if condition true | `if (bad) S.raiseError(e) else S.unit` | `S.raiseWhen(bad)(e)` |
| Raise error if condition false | `if (!good) S.raiseError(e) else S.unit` | `S.raiseUnless(good)(e)` |
| Conditionally run an effect | `if (cond) action else S.unit` | `S.whenA(cond)(action)` |
| Option to F, None as error | `opt.fold(S.raiseError(e))(S.pure)` | `opt.liftTo[F](e)` |
| Either to F, Left as error | `either.fold(S.raiseError, S.pure)` | `either.liftTo[F]` |
| Inspect or recover both sides | `.attempt.flatMap { case Right(v) => ... case Left(e) => ... }` | `.redeemWith(e => ..., v => ...)` |
| Transform error, keep failing | `.handleErrorWith(e => S.raiseError(wrap(e)))` | `.adaptErr { case e => wrap(e) }` |
