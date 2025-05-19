# Adjusting Package Shipments for Remote TimeZones

## Introduction

This enhancement to the Package Automation feature supports delayed package shipments to destinations which have limited windows of time when new software may be delivered. Freqeuently these shipment Destinations reside on timezones that are different from the one where package shipping is initiated.

The references to time when shipments are allowed, may be designated for the timezone targeted by package shipment. For example, if you package shipment is initiated in the "US/Eastern" timezone, and ships to the "Singapore" timezone, then the time value indicated on the SHIPRULE table will be the "Singapore" time.

This solution is dependent upon the [Time API | Time Zone API](https://timeapi.io) for performing time zone time conversions. See [TimeApi Swagger](https://timeapi.io/swagger/index.html) for details.

When a Timezone is entenred onto the SHIPRULE table, then the BILDTGGR (ond other REXX programs) can convert the remote time to a local time using a REXX statement like this one...

    TriggerDateTime = DTADJUST(remoteTimeZone remoteTime DaysIncrement) 
    Say "Remote" RemoteDateTime                                         

Where values passed to the DTADJUST routine are pulled from a SHIPRULE table, and affect the timing of package shipments to the destination. 
        
- **remoteTimeZone** a Timezone value, listed among those presented by the  **TimeTestAvailableTimezones.py** program.             

- **remoteTime** the earliest time of the day when shipping is allowed. The time is given in the hh:mm:ss format for the remoteTimeZone          

- **DaysIncrement** a number of days (0 to any integer) designating required full days to delay package shipments from the package execution date and tim.
               
               
## Supporting Folder items
                                                                     

**DTADJUST.rex** - this REXX routine can be called with variables extracted from a SHIPRULE row, and will return local date and time values to be entered onto the Trigger file for a shipment. This REXX calls the **TimeZoneConvert.py** python program, and provides local date and time values for a shipment to the Destination. The time zone for the local date and time values are given according to the localTimezone as defined in **TimeZoneConvert.py**. 

**TimeZoneConvert.py** - is the Python code that engages the **Conversion/ConvertTimeZone** API to convert times from other timezones to the one defined internally as the localTimezone. Initially, the value of the **localTimeZone** is set to:

    localTimezone = "US/Eastern"

Two additional Python programs are provided for convenience. These might be helpful during the initial startup, but are not permanent components of this configuration. 

- **TimeTestAvailableTimezones.py**  - gives a list of all Timezones supported by the [Time API | Time Zone API](https://timeapi.io)

- **TimeZoneTest.py** - gets information about the referenced timezone, includeing the "currentLocalTime".

## The SHIPRULE Table

This feature allows you to enter a TimeZone onto your SHIPRULE table.
>
    **Environment Stage System-- Subsys-- Destination St Jobname-  Date TimeZone--------- Time  Typrun

When a row on the table has a non-blank value under the TimeZone and a time value in the Time column, the time specified, is a time value for the designated TimeZone, and is the earliest time that shipments should be allowed at the Destination.  