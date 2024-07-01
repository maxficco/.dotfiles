from datetime import datetime

def days_from_date(year, month, day):
    date_given = datetime(year, month, day)
    current_date = datetime.now()
    difference = current_date - date_given
    return difference.days

print(days_from_date(2006,5,26))
