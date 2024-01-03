
exports.init =  async function(app) {

    console.log("I am starting the calendar");

    var calendarJs = document.createElement('script');
    calendarJs.type = 'text/javascript';
    calendarJs.onload = function() {
        console.log("calendarJs loading");
        initCalendar();
    };
    
    calendarJs.src = "https://cdn.skypack.dev/calendar-native-web-component@0.0.32";

    document.head.appendChild(calendarJs);
    console.log("I have appended calendarJs to document.head");


    function initCalendar() {

        console.log("Initializing custom element full-calendar (FullCalendar)");

        class DatePicker extends HTMLElement {
            constructor() {
                super();

                // Create a shadow root
                this.attachShadow({ mode: 'open' });

                // Create element
                const wrapper = document.createElement('div');
                wrapper.setAttribute('class', 'date-picker');

                const datePicker = document.createElement('date-picker');
                datePicker.setAttribute('id', 'date-picker');
                datePicker.setAttribute('primary-color', '#7048EB');
                datePicker.setAttribute('secondary-color', '#302F32');
                datePicker.setAttribute('header-text-color', '#fff');
                datePicker.setAttribute('day-text-color', '#fff');
                datePicker.setAttribute('day-names', 'Mo, Di, Mi, Do, Fr, Sa, So');
                datePicker.setAttribute('selected-text-color', '#fff');
                datePicker.setAttribute('disabled-text-color', '#666');
                datePicker.setAttribute('today-border-color', '#7048EB');
                datePicker.setAttribute('month-names', 'January, February, March, April, May, June, July, August, September, October, November, December');

                // Append the date picker to the wrapper
                wrapper.appendChild(datePicker);

                // Append the wrapper to the shadow root
                this.shadowRoot.appendChild(wrapper);
            }
        }

       // Define the new element
        customElements.define(' date-picker', DatePicker);

    }
}


// SOURCE: https://www.skypack.dev/view/calendar-native-web-component