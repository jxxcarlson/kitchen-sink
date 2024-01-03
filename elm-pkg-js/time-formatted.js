
exports.init =  async function(app) {

    console.log("I am starting time-formattedr");
        initTimeFormatted();
    };

    // https://javascript.info/custom-elements#example-time-formatted

    function initTimeFormatted() {

        console.log("Initializing custom element full-calendar (FullCalendar)");


        class TimeFormatted extends HTMLElement {
            render() {
                let date = new Date(this.getAttribute('datetime') || Date.now());

                this.innerHTML = new Intl.DateTimeFormat("default", {
                    year: this.getAttribute('year') || undefined,
                    month: this.getAttribute('month') || undefined,
                    day: this.getAttribute('day') || undefined,
                    hour: this.getAttribute('hour') || undefined,
                    minute: this.getAttribute('minute') || undefined,
                    second: this.getAttribute('second') || undefined,
                    timeZoneName: this.getAttribute('time-zone-name') || undefined,
                }).format(date);
            }


            static get observedAttributes() {
                return ['datetime', 'year', 'month', 'day', 'hour', 'minute', 'second', 'time-zone-name'];
            }

            attributeChangedCallback(name, oldValue, newValue) {
                this.render();
            }

            connectedCallback() {
                if (!this.rendered) {
                    this.render();
                    this.rendered = true;
                    this.startAutoUpdate();
                }
            }

            startAutoUpdate() {
                this.interval = setInterval(() => {
                    this.setAttribute('datetime', new Date().toISOString());
                }, 1000);
            }

            disconnectedCallback() {
                clearInterval(this.interval);
            }
        }

        customElements.define("time-formatted", TimeFormatted);



}
