from pathlib import Path
import json
from typing import List, Dict

THIS_DIR = Path(__file__).parent
CITIES_JSON_PATH = THIS_DIR / "./cities.json"


def is_city_capital_of_state(city_name: str, state: str) -> bool:
    cities_json_contents = CITIES_JSON_PATH.read_text()
    cities: List[dict] = json.loads(cities_json_contents)
    matching_cities: List[dict] = [_city for _city in cities if _city["city"] == city_name]
    if len(matching_cities) == 0:
        return False
    matched_city = matching_cities[0]
    return matched_city["state"] == state


if __name__ == "__main__":
    is_capital = is_city_capital_of_state(city_name="Montgomery", state="Alabama")
    print(is_capital)
