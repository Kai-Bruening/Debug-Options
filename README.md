# Debug-Options
Beispielprojekte zum Artikel „Besser debuggen“ in Mac&amp;i, Heft 2/2020

Das Repository enthält einen Xcode-Workspace mit drei Projekten: je einem Framework-Projekt mit dem Objective-C-Code für die Debug-Optionen (Foundation-Ebene) und das Debug-Menü (UI-Ebene) sowie einem Projekt mit meinen Versuchen in Swift. Alle Projekte haben getrennte Targets für macOS und iOS.

Auf der Foundation-Ebene sind ein paar Unit-Tests dabei, für das Debug-Menü gibt es stattdessen Test-Apps, mit denen sich die Menüs ausprobieren lassen. Diese Apps sind in den Framework-Schemas als Executable in der Run-Tafel eingebunden: eine bewährte Methode, um Test-Apps direkt von Framework-Schemas zu starten.

Der Code darf ohne Einschränkungen frei verwendet werden. Er wird von der ProjectWizards GmbH „as is“ und ohne jegliche Garantie oder Gewährleistung zur Verfügung gestellt. Pflege oder Weiterentwicklung sind nicht geplant.

## English

Example projects for the article "Besser debuggen" in Mac&i, issue 2/2020

The repository contains an Xcode workspace with three projects: one framework project each with the Objective-C code for the debug options (Foundation level) and the debug menu (UI level) and one project with my experiments in Swift. All projects have separate targets for macOS and iOS.

On the foundation level there are some unit tests, for the debug menu there are test apps instead to try out the menus. These apps are included in the framework schemas as executables in the run panel: a proven method to start test apps directly from framework schemas.

The code can be used freely without restrictions. It is provided by ProjectWizards GmbH "as is" and without any warranty or guarantee. Maintenance or further development is not planned.
