# Python Testing Rules

Applies to: `**/*.py`

Implements the core principles from `testing.md`. All rules there apply here —
this file covers Python-specific patterns.

## Framework: pytest (NEVER unittest)

Use `pytest` for all Python tests. Do not use `unittest.TestCase` unless
integrating with legacy code that requires it.

## Test Structure

Group tests in classes that mirror the source module:

```python
class TestCartService:
    """Tests for CartService."""

    @pytest.fixture
    def cart(self):
        return Cart(user_id=42)

    def test_add_item_normal(self, cart):
        """Normal: adding an in-stock item increases quantity."""
        cart.add("SKU-1", quantity=2)
        assert cart.item_count("SKU-1") == 2

    def test_add_item_boundary_zero_quantity(self, cart):
        """Boundary: quantity 0 is a no-op, not an error."""
        cart.add("SKU-1", quantity=0)
        assert cart.item_count("SKU-1") == 0

    def test_add_item_error_negative(self, cart):
        """Error: negative quantity raises ValueError."""
        with pytest.raises(ValueError, match="quantity must be non-negative"):
            cart.add("SKU-1", quantity=-1)
```

## Fixtures Over Factories

- Use `pytest` fixtures for test data setup
- Use `@pytest.fixture(autouse=True)` sparingly — prefer explicit injection
- Avoid `factory_boy` unless object graphs are genuinely complex
- Django: prefer pytest fixtures over `setUpTestData` unless you have a
  performance reason

## Parametrize for Category Coverage

Use `@pytest.mark.parametrize` to cover normal, boundary, and error cases
concisely instead of hand-writing near-duplicate tests:

```python
@pytest.mark.parametrize("quantity,valid", [
    (1, True),       # Normal
    (100, True),     # Normal: bulk
    (0, True),       # Boundary: zero is a no-op
    (-1, False),     # Error: negative
])
def test_add_item_quantity_validation(cart, quantity, valid):
    if valid:
        cart.add("SKU-1", quantity=quantity)
    else:
        with pytest.raises(ValueError):
            cart.add("SKU-1", quantity=quantity)
```

### Pairwise / Combinatorial for Parameter-Heavy Functions

When `@pytest.mark.parametrize` would require listing dozens of combinations
(feature flags × permissions × shipping × payment × etc.), switch to
combinatorial coverage via `/pairwise-tests`. The skill generates a minimal
matrix covering every 2-way parameter interaction — typically 80-99% fewer
cases than exhaustive, catching most combinatorial bugs.

Workflow: invoke `/pairwise-tests` → get a PICT model + generated test matrix
→ paste the matrix into a pytest parametrize block, or use the helper to
emit directly. The `pypict` package (`pip install pypict`) handles
generation in-process.

See `testing.md` § Combinatorial Coverage for the general rule and when
to skip.

## Mocking Guidelines

### Mock these (external boundaries):
- External APIs (`requests`, `httpx`, `boto3` clients)
- Time (`freezegun` or `time-machine`)
- File uploads (Django: `SimpleUploadedFile`)
- Celery tasks (`@override_settings(CELERY_ALWAYS_EAGER=True)`)
- Email sending (Django: `django.core.mail.outbox`)

### Never mock these (internal domain):
- ORM queries (SQLAlchemy, Django ORM)
- Model methods and properties
- Form and serializer validation
- Middleware
- Your own service functions

## Async Testing

Use `anyio` for async tests (not raw `asyncio`):

```python
@pytest.mark.anyio
async def test_process_order_async():
    result = await process_order_async(sample_order)
    assert result.status == "processed"
```

## Database Testing (Django)

- Mark database tests with `@pytest.mark.django_db`
- Use transactions for isolation (pytest-django default)
- Prefer in-memory SQLite for speed in unit tests
- Use `select_related` / `prefetch_related` assertions to catch N+1 regressions
