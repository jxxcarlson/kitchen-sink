
exports.init =  async function(app) {

    console.log("I am starting full-calendar");

    var calendarJs = document.createElement('script');
    calendarJs.type = 'text/javascript';
    calendarJs.onload = function() {
        console.log("calendarJs loading");
        document.head.appendChild(calendarJs);
        console.log("I have appended calendarJs to document.head");
        loadCalendarCoreJs();
        loadDayGridJs()

        initCalendar();
    };

    calendarJs.src = "https://cdn.jsdelivr.net/npm/@fullcalendar/web-component@6.1.10/index.global.min.js";

    function loadCalendarCoreJs() {
        var calendarCore = document.createElement('script');
        calendarCore.type = 'text/javascript';
        calendarCore.onload = function() {
            console.log("calendarCore loaded");
        };

        calendarCoreJs.src = "https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.10/index.global.min.js    ";

        document.head.appendChild(calendarCoreJs);
        console.log(" I have appended calendarCoreJs to document.head");
    }

    function loadDayGridJs() {
        var dayGrid = document.createElement('script');
        dayGrid.type = 'text/javascript';
        dayGrid.onload = function() {
            console.log("dayGrid loaded");
        };

        dayGridJs.src = "https://cdn.jsdelivr.net/npm/@fullcalendar/daygrid@6.1.10/index.global.min.js";

        document.head.appendChild(dayGrid);
        console.log(" I have appended dayGrid to document.head");
    }


    function initCalendar() {

        console.log("Initializing custom element full-calendar (FullCalendar)");

        class Calendar extends HTMLElement {
            constructor() {
                super();

                // Create a shadow root
                this.attachShadow({ mode: 'open' });

                // Create element
                const wrapper = document.createElement('div');
                wrapper.setAttribute('class', 'full-calendar');

                const calendar = document.createElement('full-calendar');
                calendar.setAttribute('id', 'date-picker');
                calendar.setAttribute('primary-color', '#7048EB');
                calendar.setAttribute('secondary-color', '#302F32');
                calendar.setAttribute('header-text-color', '#fff');
                calendar.setAttribute('day-text-color', '#fff');
                calendar.setAttribute('day-names', 'Mo, Di, Mi, Do, Fr, Sa, So');
                calendar.setAttribute('selected-text-color', '#fff');
                calendar.setAttribute('disabled-text-color', '#666');
                calendar.setAttribute('today-border-color', '#7048EB');
                calendar.setAttribute('month-names', 'January, February, March, April, May, June, July, August, September, October, November, December');

                // Append the date picker to the wrapper
                wrapper.appendChild(calendar);

                // Append the wrapper to the shadow root
                this.shadowRoot.appendChild(wrapper);
            }
        }

        // Define the new element
        customElements.define(' my-calendar', Calendar);

    }
}


// SOURCE: https://www.skypack.dev/view/calendar-native-web-component