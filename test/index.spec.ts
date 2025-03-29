import { env, createExecutionContext, waitOnExecutionContext, SELF } from 'cloudflare:test';
import { describe, it, expect } from 'vitest';
import worker from '../src/index';
import install from '../src/install.sh';


const MockedRequest = Request<unknown, IncomingRequestCfProperties>;

describe('get.cardinal.run', () => {
	it('redirects to https://cardinal.run/ when user agent is unknown', async () => {
		const request = new MockedRequest('https://get.cardinal.run');
		const ctx = createExecutionContext();

		const response = await worker.fetch(request, env, ctx);
		await waitOnExecutionContext(ctx);

		expect(response.status).equals(301);
		expect(response.headers.get('location')).equals('https://cardinal.run/');
	});

	it('returns the install script when the user agent is known', async () => {
		const request = new MockedRequest('https://get.cardinal.run', {
			headers: {'user-agent': 'curl'}
		});
		const ctx = createExecutionContext();

		const response = await worker.fetch(request, env, ctx);
		await waitOnExecutionContext(ctx);

		expect(response.status).not.equals(301);
		expect(await response.text()).equals(install);
	});
});
