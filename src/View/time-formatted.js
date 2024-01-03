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

// <!doctype html>
// <html>
// <body>
// <time-formatted id="elem" hour="numeric" minute="numeric" second="numeric"></time-formatted>
//
// <script src="path/to/your/javascriptfile.js"></script>
// <script>
// setInterval(() => elem.setAttribute('datetime', new Date()), 1000);
// </script>
// </body>
// </html>
    connectedCallback() {
        if (!this.rendered) {
            this.render();
            this.rendered = true;
        }
    }

    static get observedAttributes() {
        return ['datetime', 'year', 'month', 'day', 'hour', 'minute', 'second', 'time-zone-name'];
    }

    attributeChangedCallback(name, oldValue, newValue) {
        this.render();
    }
}

customElements.define("time-formatted", TimeFormatted);
