import http from 'k6/http';
import {check} from 'k6';

export const options = {
    vus: 1000,
    duration: '10s',
};

const params = {
    headers: {"Content-Type": "application/json"},
};

export default function () {
    const url = __ENV.URL || 'http://localhost:9999';
    const res = http.post(`${url}`, "{\"key\":\"value\"}", params);
    check(res, {
        'status 200': (r) => r.status === 200,
    });
}
