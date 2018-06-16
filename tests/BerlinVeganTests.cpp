
#include <tests/OpeningHoursAlgorithmsTests.h>

int main(int argc, char *argv[])
{
    QTest::qExec(new OpeningHoursAlgorithms_TestIsPublicHoliday(), argc, argv);
    QTest::qExec(new OpeningHoursAlgorithms_TestIsShortAfterMidnight(), argc, argv);
}
