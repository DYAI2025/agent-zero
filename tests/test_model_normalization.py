from models import normalize_model_name


def test_normalize_model_name_trims_and_hyphenates_whitespace():
    assert normalize_model_name(" openai / gpt-4o mini ") == "openai/gpt-4o-mini"


def test_normalize_model_name_leaves_clean_values_unchanged():
    assert normalize_model_name("openai/gpt-4.1-mini") == "openai/gpt-4.1-mini"
