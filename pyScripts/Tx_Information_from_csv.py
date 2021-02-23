from Data_Helpers import get_tx_loc_from_csv
import sys

def main():
    filename = sys.argv[1]
    print(get_tx_loc_from_csv(filename))

if __name__ == "__main__":
    main()
