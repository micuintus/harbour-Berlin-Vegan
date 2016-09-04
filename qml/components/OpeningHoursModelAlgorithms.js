.pragma library

function cleanUpOpeningHoursModel(openingHoursModel)
{
    var count = openingHoursModel.count;
    for (var i = 0; i < count; i++)
    {
        if (openingHoursModel.get(i).hours === "")
        {
            openingHoursModel.set(i, {"hours":qsTr("closed")});
        }
        else while (i < count && openingHoursModel.get(i).hours === "flagDeleteDummy")
        {
            openingHoursModel.remove(i);
            count--;
        }
    }
}

function mergeElements(openingHoursModel, from, to)
{
    var fromElementDay = openingHoursModel.get(from).day;
    var toElementDay   = openingHoursModel.get(to).day;
    var hours          = openingHoursModel.get(from).hours

    openingHoursModel.set(from, {"day":fromElementDay + " - " + toElementDay, "hours":hours});

    for (var i = from + 1; i <= to; i++)
    {
        openingHoursModel.set(i, {"day":"flagDeleteDummy", "hours":"flagDeleteDummy"});
    }
}

function condenseOpeningHoursModel(openingHoursModel)
{
    var initSize = openingHoursModel.count;
    var lastEqualItemIndex = -1;

    if (initSize <= 1)
    {
        return;
    }

    // iterating from the first to the second last item, models are 0 indexed
    for (var i = 0; i <= initSize - 2 ; i++)
    {
        var currElem = openingHoursModel.get(i);
        var nextElem = openingHoursModel.get(i+1);

        if (currElem.hours === nextElem.hours)
        {
            if (lastEqualItemIndex === -1)
            {
                lastEqualItemIndex = i;
            }

            if (i === initSize - 2)
            {
                mergeElements(openingHoursModel, lastEqualItemIndex, i + 1);
            }

        }
        else
        {
            if (lastEqualItemIndex !== -1)
            {
                mergeElements(openingHoursModel, lastEqualItemIndex, i);
                lastEqualItemIndex = -1;
            }
        }
    }

    cleanUpOpeningHoursModel(openingHoursModel);
}
