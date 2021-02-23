from Data_Helpers import get_tx_sector_orientations
import sys

def main():
    filename = sys.argv[1]
    print(get_tx_sector_orientations(filename))

if __name__ == "__main__":
    main()
