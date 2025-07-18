import http from 'k6/http';
import {check, sleep} from 'k6';

export const options = {
    discardResponseBodies: true,
    scenarios: {
        // prepare events for 30s
        send_requests: {
            executor: "constant-vus",
            vus: 1000,
            duration: "30s",
        },

        after_callback: {
            executor: "per-vu-iterations",
            vus: 1,
            iterations: 1,
            startTime: "35s",
            exec: "afterCallback",
        },
    },
};

const payload = JSON.stringify({
    event_type: "delay-100ms",
    data: {key: "value"},
});

const params = {
    headers: {"Content-Type": "application/json"},
};

export default function () {
    const url = __ENV.URL || 'http://localhost:9600';
    const res = http.post(`${url}`, payload, params);
    check(res, {
        'status 200': (r) => r.status === 200,
    });
}

function parseRequests(status) {
    let lines = status.trim().split("\n");
    let nums = lines[2].trim().split(/\s+/);
    return parseInt(nums[2])
}

export function afterCallback() {
    let start = Date.now();
    let res1 = http.get("http://upstream:9999/nginx_status", {responseType: "text"});
    let requests1 = parseRequests(res1.body);
    sleep(10);
    let res2 = http.get("http://upstream:9999/nginx_status", {responseType: "text"});
    let requests2 = parseRequests(res2.body);
    let elapsed = (Date.now() - start) / 1000.0
    let requests = requests2 - requests1
    console.log("total requests:", requests);
    console.log("elapsed:", elapsed, "s");
    console.log("RPS: ", requests / elapsed, "/s");
}
