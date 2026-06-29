//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>

//+------------------------------------------------------------------+
input string input_info_time = "=== CONFIGURAÇÕES DE HORÁRIO ==="; //-
input string time_restriction =
    "9:00-9:15,10:00-10:20,12:00-13:00,17:00-19:00"; // Restrições de horários separados por vírgula (HH:MM-HH:MM,...)

//+------------------------------------------------------------------+
class TimeWindow: public CObject
{
    int hourBegin, hourEnd, minuteBegin, minuteEnd;
    int lastHour, lastMinute;
    bool allowed, lastIsAllowed;
    bool useMinute, changed;

public:
    TimeWindow(int begin_hour, int begin_min, int end_hour, int end_min)
        : hourBegin(begin_hour), minuteBegin(begin_min), hourEnd(end_hour), minuteEnd(end_min), lastHour(0),
          lastMinute(0), allowed(false), lastIsAllowed(false), useMinute(true)
    {
        PrintFormat("Nova Configuração de Restrição de horário: Início: %.2d:%.2d Final: %.2d:%.2d",
                    hourBegin,
                    minuteBegin,
                    hourEnd,
                    minuteEnd);
    }

    string get_begin_time()
    {
        return StringFormat("%.2d:%.2d", hourBegin, minuteBegin);
    }
    string get_end_time()
    {
        return StringFormat("%.2d:%.2d", hourEnd, minuteEnd);
    }
    string get_info_time()
    {
        return StringFormat("Restrição de Horário (%s - %s): %s",
                            get_begin_time(),
                            get_end_time(),
                            allowed ? "OK" : "Aguardando");
    }

    //+------------------------------------------------------------------+
    bool timeIsChanged()
    {
        return changed;
    }
    //+------------------------------------------------------------------+
    bool timeIsAllowed()
    {
        return allowed;
    }
    //+------------------------------------------------------------------+
    void updateIfTimeIsAllowed(MqlDateTime &time)
    {
        lastIsAllowed = allowed;
        allowed = true;
        changed = false;

        if (time.hour >= hourBegin && time.hour <= hourEnd) {
            allowed = false;
            if (time.hour == hourBegin) {
                if (time.min < minuteBegin)
                    allowed = true;
            }
            if (time.hour == hourEnd) {
                if (time.min >= minuteEnd)
                    allowed = true;
            }
        }

        lastHour = time.hour;
        lastMinute = time.min;
        if (allowed != lastIsAllowed) {
            changed = true;
        }
    }
};

//+------------------------------------------------------------------+
class TimeController
{
public:
    CArrayObj time_window_array;
    bool allowed;

    TimeController() : time_window_array(), allowed(false)
    {
        time_window_array.FreeMode(true);
        string schedules[];
        int schedules_size = StringSplit(time_restriction, StringGetCharacter(",", 0), schedules);
        for (int i = 0; i < schedules_size; i++) {
            string time_values[];
            int time_values_size = StringSplit(schedules[i], StringGetCharacter("-", 0), time_values);
            if (time_values_size == 2) {
                string time_begin[], time_end[];

                int time_begin_size = StringSplit(time_values[0], StringGetCharacter(":", 0), time_begin);
                int time_end_size = StringSplit(time_values[1], StringGetCharacter(":", 0), time_end);

                if (time_begin_size == 2 && time_end_size == 2) {
                    int begin_hour = (int)StringToInteger(time_begin[0]);
                    int begin_min = (int)StringToInteger(time_begin[1]);
                    int end_hour = (int)StringToInteger(time_end[0]);
                    int end_min = (int)StringToInteger(time_end[1]);

                    time_window_array.Add(new TimeWindow(begin_hour, begin_min, end_hour, end_min));
                }
            }
        }
    }
    //+------------------------------------------------------------------+
    void Update() {
        int total = time_window_array.Total();
        TimeWindow *time_window;
        MqlDateTime mdt;
        TimeCurrent(mdt);
        allowed = true;

        for (int i = 0; i < total; i++) {
            time_window = timeCtrl.time_window_array.At(i);
            time_window.updateIfTimeIsAllowed(mdt);
            allowed = allowed && time_window.timeIsAllowed();
        }
    }
    //+------------------------------------------------------------------+
    bool IsAllowed() {
        return allowed;
    }

};
//+------------------------------------------------------------------+