-- Definiciones pg_get_functiondef() proporcionadas por el usuario: 2026-11-03.
-- Solo se retiraron escapes de formato del mensaje; lógica y firmas intactas.
-- Las ACL finales reproducen los permisos reportados por separado.
-- Transacción y search_path de restauración; no cambian el SET de las funciones.
BEGIN;
SET LOCAL search_path = pg_catalog, public;

CREATE OR REPLACE FUNCTION public.reservar_alerta_incidente(
    p_tipo_incidente text
)
RETURNS TABLE(debe_notificar boolean, token_reserva uuid)
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
DECLARE
    v_token UUID := gen_random_uuid();
    v_reservado UUID;
BEGIN
    IF p_tipo_incidente NOT IN (
        'meta_autenticacion',
        'meta_facturacion'
    ) THEN
        RAISE EXCEPTION 'Tipo de incidente no permitido';
    END IF;

    INSERT INTO public.whatsapp_incident_alerts AS actual (
        tipo_incidente,
        reserva_id,
        reserva_hasta
    )
    VALUES (
        p_tipo_incidente,
        v_token,
        NOW() + INTERVAL '5 minutes'
    )
    ON CONFLICT (tipo_incidente)
    DO UPDATE SET
        reserva_id = EXCLUDED.reserva_id,
        reserva_hasta = EXCLUDED.reserva_hasta,
        actualizado_en = NOW()
    WHERE (
        actual.ultimo_aviso_en IS NULL
        OR actual.ultimo_aviso_en <= NOW() - INTERVAL '24 hours'
    )
    AND (
        actual.reserva_hasta IS NULL
        OR actual.reserva_hasta <= NOW()
    )
    RETURNING actual.reserva_id INTO v_reservado;

    RETURN QUERY
    SELECT v_reservado IS NOT NULL, v_reservado;
END;
$function$;

CREATE OR REPLACE FUNCTION public.confirmar_alerta_incidente(
    p_tipo_incidente text,
    p_token_reserva uuid,
    p_enviado boolean
)
RETURNS boolean
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
DECLARE
    v_filas INTEGER;
BEGIN
    IF p_enviado IS NULL THEN
        RAISE EXCEPTION 'Estado de envío obligatorio';
    END IF;

    UPDATE public.whatsapp_incident_alerts
    SET
        ultimo_aviso_en = CASE
            WHEN p_enviado THEN NOW()
            ELSE ultimo_aviso_en
        END,
        reserva_id = NULL,
        reserva_hasta = NULL,
        actualizado_en = NOW()
    WHERE tipo_incidente = p_tipo_incidente
      AND reserva_id = p_token_reserva;

    GET DIAGNOSTICS v_filas = ROW_COUNT;

    RETURN v_filas = 1;
END;
$function$;

-- Permisos reportados: sin EXECUTE para PUBLIC, anon o authenticated.
REVOKE ALL PRIVILEGES ON FUNCTION public.reservar_alerta_incidente(text)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reservar_alerta_incidente(text)
    TO service_role, postgres;

REVOKE ALL PRIVILEGES ON FUNCTION public.confirmar_alerta_incidente(text, uuid, boolean)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirmar_alerta_incidente(text, uuid, boolean)
    TO service_role, postgres;

COMMIT;
