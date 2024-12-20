import win32com.client
import pandas as pd
from bs4 import BeautifulSoup
import re
import argparse
import os

# CLI argument parsing
def parse_arguments():
    parser = argparse.ArgumentParser(description="Scan mailbox for emails matching a subject line pattern, check for tables, and extract specific table data to Excel file")
    parser.add_argument('-o', '--output-folder', type=str, default=".\\output", help="Folder to save the Excel files (default: .\\output)")
    parser.add_argument('-c', '--columns', type=str, default="2, 4, 5, 6, 7", help="Table columns to extract (remember the first column is 0)")
    parser.add_argument('-p', '--print', type=str, default="5", help="Table column(s) to print")
    parser.add_argument('-e', '--email', type=str, default="My Mailbox", help="Email address or Mailbox display name to use for the Outlook connection")
    parser.add_argument('-f', '--folder-path', type=str, default="Inbox/My Folder", help="Path to the target folder in the format: 'Inbox/Subfolder1/Subfolder2'")
    parser.add_argument('-l', '--limit', type=int, default=3, help="Number of emails to extract from (useful to shorten the output for readability or sanity testing)")
    parser.add_argument('-q', '--quiet', action=argparse.BooleanOptionalAction, help="Quiet mode: suppresses status messages")
    parser.add_argument('-a', '--additional-output', action=argparse.BooleanOptionalAction, help="Print columns specified with --print as a comma separated list")
    parser.add_argument('-b', '--banner', action=argparse.BooleanOptionalAction, help="Print the title banner")

    return parser.parse_args()

# Format a banner message
def print_banner(text, symbol):
    banner_length = len(text) + 4
    print(symbol * banner_length)
    print(symbol, text, symbol)
    print(symbol * banner_length)

# Access a specified mailbox
def connect_to_outlook(target_mailbox, folder_path):
    outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")

    # Access the mailbox
    try:
        mailbox = outlook.Folders.Item(target_mailbox) #.Folders.Item(folder)

        # Navigate through the folder path
        target_folder = mailbox
        for folder_name in folder_path:
            target_folder = target_folder.Folders.Item(folder_name)

        return target_folder
    
    except Exception as e:
        print(f"Error accessing folder: {e}")
        return None

# Extract the HTML table
def extract_table_from_email(body):
    soup = BeautifulSoup(body, 'html.parser')

    table = soup.find('table', class_="MsoNormalTable")
    if not table:
        return None
    
    rows = table.find_all('tr')
    headers = [th.get_text(strip=True) for th in rows[0].find_all('th')]
    data = [
        [td.get_text(strip=True) for td in row.find_all('td')]
        for row in rows[1:] # Skip the header row
    ]

    return headers, data

# generate Excel filename
def generate_csv_filename(subject, output_folder):
    # Replace slashes in the date (MM/DD/YYYY -> MM-DD-YYYY)
    formatted_name = date_regex.sub(r'\1-\2-\3', subject)

    csv_filename = f"{formatted_name}.csv"

    # Replace any chars unsuitable for filenames
    csv_filename = "".join(c if c.isalnum() or c in [' ', '.', '_', '-'] else '_' for c in csv_filename)

    # Combine with specified output folder path
    return os.path.join(output_folder, csv_filename)

# Write specific columns to an CSV file
def save_to_csv(headers, data, column_indices, csv_file):
    filtered_data = [
        [row[i] for i in column_indices]
        for row in data
    ]

    filtered_df = pd.DataFrame(filtered_data) # , columns=[headers[i] for i in column_indices])
    filtered_df.to_csv(csv_file, header=False, index=False)

# Print selected data to the terminal
def format_data_for_terminal(headers, data, columns_to_print, separator):    
    return separator.join([row[i] for row in data for i in columns_to_print])

if __name__== "__main__":
    args = parse_arguments()

    if args.banner:
        print_banner("Offboarding Helper! v2.0", "#")
        print("script by v01dlight")
        print()

    # specify which columns to extract
    column_indices = [int(item) for item in args.columns.split(',')]

    # specify which columns to print
    columns_to_print = [int(item) for item in args.print.split(',')]

    # Filter messages by subject line matching a regex
    target_subject = re.compile(r"TODO .*", re.IGNORECASE)
    #messages = messages.Restrict(f"[Subject] = '{target_subject}'")

    # Regex to match the date format in the subject (MM/DD/YYYY)
    date_regex = re.compile(r'(\d{2})/(\d{2})/(\d{4})')

    # Ensure the output folder exists
    output_folder = args.output_folder
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Grab inbox contents
    folder_path = args.folder_path.split("/")
    mailbox = connect_to_outlook(args.email, folder_path)
    messages = mailbox.Items

    # Max number of messages to extract from
    limit = args.limit

    # Current number of messages extracted from
    num_extracted = 0

    # Initialize a variable to store collected data for each column specified with --print
    comma_separated_data = ""

    # Iterate through each email
    for message in messages:
        if num_extracted < limit:
            if message.Class == 43: # Ensure it's a mail item
                subject = message.Subject

                # Check if the email has a subject line matching our regex, and doesn't have a flag indicating it should be skipped
                if message.FlagStatus != 3 and message.FlagStatus != 1 and message.FlagStatus != 2 and re.search(target_subject, subject):
                    if not args.quiet: print(f"[+] Processing email: {subject}")

                    # debugging
                    #print(f"[!] Flag Status: {message.FlagStatus}")

                    body = message.HTMLBody # Get the HTML body

                    # Extract the table
                    table = extract_table_from_email(body)

                    if table:
                        headers, data = table

                        # Save the filtered data to Excel
                        csv_file = generate_csv_filename(subject, output_folder)
                        save_to_csv(headers, data, column_indices, csv_file)
                        if not args.quiet: print(f"[>] Data saved to {csv_file}")

                        # Mark the email as "Processed"
                        message.FlagStatus = 3
                        message.Save()

                        if not args.quiet: print(f"[+] Email marked as processed\n")

                        if args.additional_output:
                            # Check each column specified in --print and save that data
                            for col in columns_to_print:
                                comma_separated_data += format_data_for_terminal(headers, data, columns_to_print, ", ")
                                comma_separated_data += ", "


                        # Increment the extraction counter
                        num_extracted += 1
                    else:
                        if not args.quiet: print(f"[!] No table found in email\n")

    # Print comma separated lists for each column specified
    if not args.quiet: print(f"[+] Printing list for easy copy/paste to additional commands:\n")
    print(comma_separated_data)
