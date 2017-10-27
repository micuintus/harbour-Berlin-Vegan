/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2016 (c) by micu <micuintus.de> (micuintus@gmx.de).
 *
 *      <https://github.com/micuintus/harbour-Berlin-vegan>.
 *
 *  The Berlin-Vegan guide is Free Software:
 *  you can redistribute it and/or modify it under the terms of the
 *  GNU General Public License as published by the Free Software Foundation,
 *  either version 2 of the License, or (at your option) any later version.
 *
 *  Berlin-Vegan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The Berlin Vegan Guide.
 *
 *  If not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.
 *
**/

.pragma library

.import QtQuick.LocalStorage 2.0 as Sql

function dbInit()
{
    var db = Sql.LocalStorage.openDatabaseSync("BerlinVeganDB", "0.1", "Berlin Vegan SQL!", 1000000);
    try {
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS BerlinVegan(favorite_id TEXT)");
        });
    } catch (err) {
        console.log("Error creating table in database: " + err);
    };
}

function dbGetHandle()
{
    try {
        var db = Sql.LocalStorage.openDatabaseSync("BerlinVeganDB", "0.1", "Berlin Vegan SQL!", 1000000);
    } catch (err) {
        console.log("Error opening database: " + err);
    }
    return db;
}

function dbGetFavoriteIds()
{
    var db = dbGetHandle();
    var result;
    db.transaction(function (tx) {
        result = tx.executeSql("SELECT favorite_id FROM BerlinVegan");
    });
    return result;
}

function dbInsertFavoriteId(id)
{
    var db = dbGetHandle();
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO BerlinVegan VALUES(?)", [ id ]);
    });
}

function dbDeleteFavoriteId(id)
{
    var db = dbGetHandle();
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM BerlinVegan WHERE favorite_id == ?", [ id ]);
    });
}
