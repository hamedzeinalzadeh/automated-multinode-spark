from src.data import DATA_DIR
from typing import Union
import json 
from pathlib import Path

class Multinode_setup:
    def __init__(self, config_json):
        with open(config_json) as f:
            self.config_data = json.load(f)

if __name__ == '__main__':
    multinode_setup = Multinode_setup(config_json=DATA_DIR / 'system_configs.json')     
