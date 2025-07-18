import http from 'k6/http';
import {check} from 'k6';

const RPS = Number(__ENV.RPS || 1000);

export const options = {
    discardResponseBodies: true,
    scenarios: {
        test: {
            executor: "constant-arrival-rate",
            rate: RPS,
            timeUnit: "1s",
            duration: "60s",
            preAllocatedVUs: 100,
            maxVUs: 1000,
        },
    },
};

const params = {
    headers: {"Content-Type": "application/json"},
};

export default function () {
    const payload = JSON.stringify({
        event_type: "e2e-latency",
        data: {timestamp: Date.now()},
    });
    const url = __ENV.URL || 'http://localhost:9600';
    const res = http.post(`${url}`, payload, params);
    check(res, {
        'status 200': (r) => r.status === 200,
    });
}
