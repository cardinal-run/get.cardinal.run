import install from './install.sh';

export default {
    async fetch(req: Request, env: Env,  ctx: ExecutionContext) {
        const userAgent = req.headers.get('user-agent')?.toLowerCase();
        console.log(userAgent);
        if (userAgent?.includes('curl') || userAgent?.includes('wget')) {
            return new Response(install);
        }

        return Response.redirect('https://cardinal.run', 301);
    }
} satisfies ExportedHandler<Env>;
