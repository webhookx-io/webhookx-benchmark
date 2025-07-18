import http from 'k6/http';
import {check} from 'k6';

export const options = {
    discardResponseBodies: true,
    vus: 1000,
    duration: '30s',
};

const payload = JSON.stringify({
    event_type: "test",
    data: {key: "value"},
});

const params = {
    headers: {"Content-Type": "application/json"},
};

export default function () {
    const url = __ENV.URL || 'http://localhost:9600';
    const res = http.post(`${url}/sync`, payload, params);
    check(res, {
        'status 200': (r) => r.status === 200,
    });
}
