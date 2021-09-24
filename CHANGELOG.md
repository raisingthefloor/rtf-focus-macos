# Change Log
All notable changes to this project will be documented in this file.


## [Released]
- We have used Application icon of Morphic
- Application launch with Focus button
- Coredata is used for Database.

1. Focus Main Screen:
- i toggle button, mouse over (show as tooltip) displays help text.
- Use this BlockList s dynamic and populated from database (first time its empty cause no data is added on that)
- View or Edit Blocklist takes user to Settings Screen with Edit Blocklists Menu open.
- Customize Focus takes user to Settings Screen with General Settings Menu open
- For Now the time buttons shows the dialogues of break and error 
  - On 30 min buttom, "Time for a Break" dialogue display and On tapping Ok it will dismiss the dialogue
  - On 1 hr button, EDIT BLOCKLIST ERROR - ACTIVE BLOCKLIST MODAL DIALOG display
  - On Stop untill button, SCHEDULE ERROR - 2 ACTIVE SESSIONS MODAL DIALOG display

2. Settings Screen
	(a) General Settings
		(i) All data are static
	(b) Edit Blocklists
		(i) Blocklists dropdown allows you to create a Blocklist (only Name) and save to coredata
		(ii) Blocklists dropdown is dynamic and populated from database
		(iii) "Also, block these..." ->Add Website -> Dialog is dynamic which store the data with respective to block list selected.
		(iv) "Also, block these..." -> Add App -> Dialog lists apps installed on machine. On Add item, it add the data with respective to block list selected.
		(v) "Exceptions to blocked "  ->Add Website -> Dialog is dynamic which store the data with respective to block list selected.
		(vi) "Exceptions to blocked " -> Add App -> Dialog lists apps installed on machine. On Add item, it add the data with respective to block list selected.
		(Vii) "Category list" -> Static data store in database -> on click of that link it display the list of item in dialogue.
		(Viii) Below Options are static -> Schema is defined storing process is in progress 
	(c) Focus Schedule
		(i) All data are static
		(ii) Desing is still remaing 
	(d) Today's Schedule
		(i) All data are static
		(ii) Desing is still remaing
		(iii) The WeekDay Header is based on today's day (e.g. FRI)
