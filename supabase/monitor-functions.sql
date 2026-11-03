-- Definiciones pg_get_functiondef() proporcionadas por el usuario: 2026-11-03.
-- Solo se retiraron escapes de formato del mensaje; lógica y firmas intactas.
-- Las ACL finales reproducen los permisos reportados por separado.
-- Transacción y search_path de restauración; no cambian el SET de las funciones.
BEGIN;
SET LOCAL search_path = pg_catalog, public;

CREATE OR REPLACE FUNCTION public.guardar_resumen_whatsapp(
    p_waba_id text,
    p_mes date,
    p_mensajes_total integer,
    p_mensajes_gratis integer,
    p_mensajes_regulares integer,
    p_mensajes_otros integer,
    p_costo_estimado_usd numeric,
    p_consultado_en timestamp with time zone
)
RETURNS SETOF whatsapp_monitor_monthly
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
BEGIN
    RETURN QUERY
    INSERT INTO public.whatsapp_monitor_monthly AS actual (
        waba_id,
        mes,
        mensajes_total,
        mensajes_gratis,
        mensajes_regulares,
        mensajes_otros,
        costo_estimado_usd,
        consultado_en,
        actualizado_en
    )
    VALUES (
        p_waba_id,
        p_mes,
        p_mensajes_total,
        p_mensajes_gratis,
        p_mensajes_regulares,
        p_mensajes_otros,
        p_costo_estimado_usd,
        p_consultado_en,
        NOW()
    )
    ON CONFLICT (waba_id, mes)
    DO UPDATE SET
        mensajes_total = EXCLUDED.mensajes_total,
        mensajes_gratis = EXCLUDED.mensajes_gratis,
        mensajes_regulares = EXCLUDED.mensajes_regulares,
        mensajes_otros = EXCLUDED.mensajes_otros,
        costo_estimado_usd = EXCLUDED.costo_estimado_usd,
        consultado_en = EXCLUDED.consultado_en,
        actualizado_en = NOW()
    WHERE NOT (
        EXCLUDED.mensajes_total = 0
        AND EXCLUDED.costo_estimado_usd = 0
        AND (
            actual.mensajes_total > 0
            OR actual.costo_estimado_usd > 0
        )
    )
    RETURNING *;

    -- Si se bloqueó la actualización,
    -- devolver el registro existente.
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT m.*
        FROM public.whatsapp_monitor_monthly AS m
        WHERE m.waba_id = p_waba_id
          AND m.mes = p_mes;
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.registrar_alerta_whatsapp(
    p_waba_id text,
    p_mes date,
    p_umbral_mensajes integer,
    p_umbral_costo_usd numeric
)
RETURNS SETOF whatsapp_monitor_monthly
LANGUAGE sql
SET search_path TO ''
AS $function$
    UPDATE public.whatsapp_monitor_monthly
    SET
        ultimo_umbral_mensajes_avisado = GREATEST(
            ultimo_umbral_mensajes_avisado,
            p_umbral_mensajes
        ),
        ultimo_umbral_costo_avisado_usd = GREATEST(
            ultimo_umbral_costo_avisado_usd,
            p_umbral_costo_usd
        )
    WHERE waba_id = p_waba_id
      AND mes = p_mes
      AND p_umbral_mensajes >= 0
      AND p_umbral_costo_usd >= 0
    RETURNING *;
$function$;

-- Permisos reportados: sin EXECUTE para PUBLIC, anon o authenticated.
REVOKE ALL PRIVILEGES ON FUNCTION public.guardar_resumen_whatsapp(text, date, integer, integer, integer, integer, numeric, timestamp with time zone)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.guardar_resumen_whatsapp(text, date, integer, integer, integer, integer, numeric, timestamp with time zone)
    TO service_role, postgres;

REVOKE ALL PRIVILEGES ON FUNCTION public.registrar_alerta_whatsapp(text, date, integer, numeric)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.registrar_alerta_whatsapp(text, date, integer, numeric)
    TO service_role, postgres;

COMMIT;
